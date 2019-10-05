import CustomAction from './CustomAction';

export default interface Action {
  type?: string;
  category?: string;
  action?: string;
  custom?: CustomAction;
}
