/* eslint-env node */

const StylelintPlugin = require('stylelint-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const WebpackBeforeBuildPlugin = require('before-build-webpack');
const CopyPlugin = require('copy-webpack-plugin');
const UglifyJS = require('uglify-js');
const concat = require('concat');
const YAML = require('yaml');
const path = require('path');
const fs = require('fs');
const PACKAGE = require('./package.json');
const sourceDir = path.resolve(__dirname, '../../srcjs');
const outputDir = path.resolve(__dirname, '../../inst');
const modulePaths = require.resolve.paths('webpack');

// dictionary for library dependency info
const libInfos = {};

function getLibDir(name, version) {
  return path.posix.join('htmlwidgets/lib', name + '-' + version);
}
function getLibFile(name, ext = '.min.js') {
  return name + ext;
}

function getLibDestJsFilename(name) {
  const info = libInfos[name];
  return path.posix.join(info.destDir, info.destJs);
}

function getLibDestCssFilename(name) {
  const info = libInfos[name];
  return path.posix.join(info.destDir, info.destCss);
}

function getLibDependencies(name) {
  if (libInfos[name].dependencies) {
    return libInfos[name].dependencies
      .map((x) => getLibDependencies(x))
      .flat()
      .concat([name]);
  }
  return [name];
}

function getDependencyInfo(name, libInfos) {
  let pkgDir = path.dirname(require.resolve(name));
  let pkgFile = path.join(pkgDir, 'package.json');
  if (!fs.existsSync(pkgFile)) {
    pkgDir = path.normalize(path.join(pkgDir, './../'));
    pkgFile = path.join(pkgDir, 'package.json');
  }
  if (!fs.existsSync(pkgFile)) {
    throw new Error('Cannot resolve package.json path for : ' + name);
  }
  const pkg = JSON.parse(fs.readFileSync(pkgFile));

  let jsFile = path.join(pkgDir, pkg.main);
  if (!fs.existsSync(jsFile)) {
    throw new Error('Cannot resolve main file for : ' + name);
  }
  if (!jsFile.endsWith('.min.js')) {
    const jsFileMin = jsFile.replace(/\.js$/, '.min.js');
    if (fs.existsSync(jsFileMin)) {
      jsFile = jsFileMin;
    }
  }
  const info = {
    name: pkg.name,
    version: pkg.version,
    srcJs: jsFile,
    srcCss: null,
    destDir: getLibDir(pkg.name, pkg.version),
    destJs: getLibFile(pkg.name),
    destCss: null
  };
  if (typeof pkg.dependencies === 'object') {
    const dependencies = Object.keys(pkg.dependencies).filter((d) =>
      d.startsWith('d3')
    );
    if (dependencies.length > 0) {
      info.dependencies = dependencies;
    }
  }
  libInfos[pkg.name] = info;
  if (info.dependencies) {
    info.dependencies
      .filter((x) => Object.keys(libInfos).indexOf(x) === -1)
      .forEach((x) => getDependencyInfo(x, libInfos));
  }
}

module.exports = (env, argv) => {
  // collect dependency info
  Object.keys(PACKAGE.dependencies).forEach((x) =>
    getDependencyInfo(x, libInfos)
  );

  // add custom d3 bundle
  libInfos['d3-bundle'] = {
    name: 'd3-bundle',
    version: libInfos.d3.version,
    destDir: getLibDir('d3-bundle', libInfos.d3.version),
    destJs: getLibFile('d3-bundle'),
    dependencies: ['d3-selection', 'd3-transition', 'd3-zoom']
  };

  // add generated library
  libInfos[PACKAGE.name] = {
    name: PACKAGE.name,
    version: PACKAGE.version,
    destDir: getLibDir(PACKAGE.name, PACKAGE.version),
    destJs: getLibFile(PACKAGE.name),
    destCss: getLibFile(PACKAGE.name, '.min.css')
  };

  // config for the js source
  const jsConfig = {
    name: 'jsConfig',
    entry: path.resolve(sourceDir, 'factory.js'),
    output: {
      path: outputDir,
      filename: getLibDestJsFilename(PACKAGE.name),
      library: PACKAGE.name,
      libraryTarget: 'umd'
    },
    externals: ['d3','flatbush'],
    module: {
      rules: [
        {
          enforce: 'pre',
          test: /\.js$/,
          exclude: /node_modules/,
          loader: 'eslint-loader',
          options: {
            configFile: '.eslintrc.yaml',
            fix: true
          }
        },
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                [
                  '@babel/preset-env',
                  {
                    modules: false,
                    debug: argv.mode == 'development',
                    useBuiltIns: 'usage',
                    corejs: '3',
                    exclude: ['es.promise']
                  }
                ]
              ]
            }
          }
        }
      ]
    },
    resolve: {
      modules: modulePaths
    },
    resolveLoader: {
      modules: modulePaths
    },
    plugins: [
      // copy libs
      new CopyPlugin({
        patterns: [
          {
            from: libInfos['save-svg-as-png'].srcJs,
            to: getLibDestJsFilename('save-svg-as-png'),
            transform(content, path) {
              return UglifyJS.minify(content.toString()).code.toString();
            }
          },
          {
            from: libInfos['d3-lasso'].srcJs,
            to: getLibDestJsFilename('d3-lasso')
          },
          {
            from: libInfos['flatbush'].srcJs,
            to: getLibDestJsFilename('flatbush'),
            transform(content, path) {
              return UglifyJS.minify(content.toString()).code.toString();
            }
          }
        ]
      }),

      // handle d3 bundle and htmlwidgets yaml
      new WebpackBeforeBuildPlugin(
        function (stats, callback) {
          // get the overall dependencies of the d3-bundle in order
          let depList = getLibDependencies('d3-bundle').flat();
          depList = [...new Set(depList)]; // unique
          // console.log('d3-bundle dependencies:', depList);
          // concatenate dependency files to a single file
          const depFiles = depList
            .map((x) => libInfos[x].srcJs)
            .filter((x) => !!x);
          const bundleFile = getLibDestJsFilename('d3-bundle');
          const bundleAbsFile = path.join(outputDir, bundleFile);
          if (!fs.existsSync(path.dirname(bundleAbsFile)))
            fs.mkdirSync(path.dirname(bundleAbsFile));
          concat(depFiles, bundleAbsFile);

          // create htmlwidgets yaml
          const depInfo = {
            dependencies: [
              'd3-bundle',
              'd3-lasso',
              'save-svg-as-png',
              'flatbush',
              PACKAGE.name
            ].map((x) => {
              const i = libInfos[x];
              const o = {
                name: x,
                version: i.version,
                src: i.destDir,
                script: i.destJs
              };
              if (i.destCss) {
                o.stylesheet = i.destCss;
              }
              return o;
            })
          };
          const yamlFile = path.posix.join(
            outputDir,
            'htmlwidgets',
            'girafe.yaml'
          );
          const yamlContents =
            '# Generated by webpack build: do not edit by hand\n' +
            YAML.stringify(depInfo);
          fs.writeFileSync(yamlFile, yamlContents);

          // done
          callback();
        },
        ['done']
      )
    ]
  };

  // config for the css source
  const cssConfig = {
    name: 'cssConfig',
    entry: path.resolve(sourceDir, 'styles.css'),
    output: {
      path: outputDir,
      filename: getLibDestCssFilename(PACKAGE.name) + '.js',
      library: PACKAGE.name
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [MiniCssExtractPlugin.loader, 'css-loader']
        }
      ]
    },
    resolve: {
      modules: modulePaths
    },
    resolveLoader: {
      modules: modulePaths
    },
    plugins: [
      new StylelintPlugin({
        configFile: '.stylelintrc.yaml',
        context: sourceDir,
        files: '*.css',
        failOnError: true,
        fix: true
      }),
      new MiniCssExtractPlugin({
        filename: getLibDestCssFilename(PACKAGE.name),
        ignoreOrder: false
      }),
      new WebpackBeforeBuildPlugin(
        function (stats, callback) {
          // remove unnecessary css.js file
          const cssjsFile = path.posix.join(
            outputDir,
            getLibDestCssFilename(PACKAGE.name) + '.js'
          );
          if (fs.existsSync(cssjsFile)) {
            fs.unlinkSync(cssjsFile);
          }
          //
          callback();
        },
        ['done']
      )
    ]
  };
  if (argv.mode == 'production') {
    cssConfig.plugins.push(new OptimizeCssAssetsPlugin());
  }

  return [jsConfig, cssConfig];
};
