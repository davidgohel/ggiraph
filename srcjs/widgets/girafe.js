import { factory } from '../modules/factory.js';
HTMLWidgets.widget({
  name: 'girafe',
  type: 'output',
  factory: factory(HTMLWidgets.shinyMode)
});
