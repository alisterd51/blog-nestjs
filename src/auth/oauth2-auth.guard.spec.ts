import { Oauth2AuthGuard } from './oauth2-auth.guard';

describe('Oauth2AuthGuard', () => {
  it('should be defined', () => {
    expect(new Oauth2AuthGuard()).toBeDefined();
  });
});
