import { ApiProperty } from "@nestjs/swagger";
import { IsString, IsUrl } from "class-validator";

export class CreatePageDto {
  @IsString()
  @ApiProperty()
  readonly path: string;

  @IsString()
  @ApiProperty()
  readonly title: string;

  @IsString()
  @ApiProperty()
  readonly summary: string;

  @IsUrl()
  @ApiProperty()
  readonly url: string;
}
