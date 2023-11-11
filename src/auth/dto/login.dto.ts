import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class LoginDto {
  @IsString()
  @ApiProperty({ example: 'test_blog_user' })
  readonly username: string;

  @IsString()
  @ApiProperty({ example: 'test_blog_pass' })
  readonly password: string;
}
