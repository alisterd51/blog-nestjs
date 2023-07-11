import { ApiProperty } from "@nestjs/swagger";
import { IsString, IsStrongPassword } from "class-validator";

export class SignInDto {
  @IsString()
  @ApiProperty()
  readonly username: string;

  @IsString()
  @ApiProperty()
  readonly password: string;
}
