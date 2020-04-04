const HtmlWebPackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
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
    filename: '[name]-0.3.0.min.js',
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
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      }
    ]
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./src/index.html",
      filename: "./index.html"
    }),
    new MiniCssExtractPlugin({
      filename: '[name]-0.3.0.min.css',
      chunkFilename: '[id].css',
      ignoreOrder: false,
    }),
    new OptimizeCssAssetsPlugin({
    })
  ]
};
