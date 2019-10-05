import ArticleTime from './ArticleTime';
import UserDB from './UserDB';
import UserId from './UserId';
import CtxSection from './CtxSection';

export default interface PageView {
  pageUrl?: string;
  pageTitle?: string;
  referrer?: string;
  userId?: UserId;
  section?: string;
  author?: string;
  pageType?: string;
  articlePublishTime?: ArticleTime;
  premium?: boolean;
  metered?: string;
  publication?: string;
  categories?: [];
  appName?: string;
  referenceNav?: string;
  articleUpdateTime?: ArticleTime;
  hierarchy?: [];
  email?: string;
  articleSource?: string;
  mediaType?: string;
  articleType?: string;
  characterCount?: string;
  wordCount?: string;
  paragraphCount?: string;
  scrollPercent?: string;
  pageNumber?: string;
  addCtxSection?: CtxSection;
  userDB?: UserDB;
}
