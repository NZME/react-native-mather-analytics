import CustomAction from './CustomAction';

export default interface Impression {
  eaid?: string;
  ebuy?: string;
  eadv?: string;
  ecid?: string;
  epid?: string;
  esid?: string;
  custom?: CustomAction;
}
