const path = require('path');
const fs = require('fs');

// defaults
var outputPath = [],
    entryPoints = [],
    externals = [],
    misc = [],
    loaders = [];

var outputPathFile = './srcjs/config/output_path.json',
    entryPointsFile = './srcjs/config/entry_points.json',
    externalsFile = './srcjs/config/externals.json',
    miscFile = './srcjs/config/misc.json',
    loadersFile = './srcjs/config/loaders.json';

// Read config files
if(fs.existsSync(outputPathFile)){
  outputPath = fs.readFileSync(outputPathFile, 'utf8');
}

if(fs.existsSync(entryPointsFile)){
  entryPoints = fs.readFileSync(entryPointsFile, 'utf8');
}

if(fs.existsSync(externalsFile)){
  externals = fs.readFileSync(externalsFile, 'utf8');
}

if(fs.existsSync(miscFile)){
  misc = fs.readFileSync(miscFile, 'utf8');
}

if(fs.existsSync(loadersFile)){
  loaders = fs.readFileSync(loadersFile, 'utf8');
}

if(fs.existsSync(loadersFile)){
  loaders = fs.readFileSync(loadersFile, 'utf8');
}

// parse
loaders = JSON.parse(loaders);
misc = JSON.parse(misc);
externals = JSON.parse(externals);
entryPoints = JSON.parse(entryPoints);

// parse regex
loaders.forEach((loader) => {
  loader.test = RegExp(loader.test);
  return(loader);
})

// placeholder for plugins
var plugins = [
];

// define options
var options = {
  entry: entryPoints,
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, JSON.parse(outputPath)),
  },
  externals: externals,
  module: {
    rules: loaders
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
  },
  plugins: plugins
};

// add misc
if(misc.resolve)
  options.resolve = misc.resolve;

// export
module.exports = options;
