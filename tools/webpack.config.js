const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const WebpackBeforeBuildPlugin = require('before-build-webpack');
const path = require('path');
const fs = require('fs');
const PACKAGE = require('./package.json');
const sourceDir = path.resolve(__dirname, '../srcjs');
const outputDir = path.resolve(__dirname, '../inst/htmlwidgets/lib');
const modulePaths = require.resolve.paths('webpack');

module.exports = (env, argv) => {
  // config for the js source
  const jsConfig = {
    name: 'jsConfig',
    entry: {
      ggiraphjs: path.resolve(sourceDir, 'factory.js')
    },
    output: {
      path: outputDir,
      filename: '[name]-' + PACKAGE.version + '/[name].min.js',
      library: '[name]',
      libraryTarget: 'umd'
    },
    externals: ['d3', 'save-svg-as-png'],
    module: {
      rules: [
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
                    debug: false
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
    plugins: []
  };

  // config for the css source
  const cssConfig = {
    name: 'cssConfig',
    entry: {
      ggiraphjs: path.resolve(sourceDir, 'styles.css')
    },
    output: {
      path: outputDir,
      filename: 'dummy.css.js'
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
      new MiniCssExtractPlugin({
        filename: '[name]-' + PACKAGE.version + '/[name].min.css',
        ignoreOrder: false
      }),
      new WebpackBeforeBuildPlugin(
        function (stats, callback) {
          // remove unnecessary css.js file
          const cssjsFile = path.join(outputDir, 'dummy.css.js');
          if (fs.existsSync(cssjsFile)) fs.unlinkSync(cssjsFile);
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
