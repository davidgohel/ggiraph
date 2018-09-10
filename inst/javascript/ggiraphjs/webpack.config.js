const HtmlWebPackPlugin = require("html-webpack-plugin");
const path = require('path');

module.exports = {
  entry: {
    ggiraphjs: [ './src/index.js']
  }, 
  externals: {
    d3: 'd3',
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name]-0.1.0.min.js',
    library: '[name]'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.html$/,
        use: [
          {
            loader: "html-loader"
          }
        ]
      }
    ]
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./src/index.html",
      filename: "./index.html"
    })
  ]
};