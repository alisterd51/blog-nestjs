import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-oauth2';
import { AuthService } from './auth.service';
import { Profile } from 'passport';
import { lastValueFrom, map } from 'rxjs';

@Injectable()
export class Oauth2Strategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({
      authorizationURL: process.env.FT_AUTHORIZATION_URL,
      tokenURL: process.env.FT_TOKEN_URL,
      clientID: process.env.FT_CLIENT_ID,
      clientSecret: process.env.FT_CLIENT_SECRET,
      callbackURL: process.env.FT_CALLBACK_URL,
    });
  }

  async validate(accessToken: string): Promise<any> {
    const data = (await lastValueFrom(this.authService.getMe(accessToken)))
      .data;
    const user42 = await this.authService.validateUser42(data.login);
    if (!user42) {
      throw new UnauthorizedException();
    }
    return user42;
  }
}
