import { Controller, Get, Post, Body, Patch, Param, Delete, ParseIntPipe } from '@nestjs/common';
import { PagesService } from './pages.service';
import { CreatePageDto } from './dto/create-page.dto';
import { UpdatePageDto } from './dto/update-page.dto';
import { Public } from '../auth/public.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { HttpService } from '@nestjs/axios';
import { Observable, map } from 'rxjs';
import { AxiosResponse } from 'axios';

@ApiTags('pages')
@Controller('pages')
export class PagesController {
  constructor(
    private readonly pagesService: PagesService,
    private readonly httpService: HttpService,
    ) {}

  @Post()
  @ApiBearerAuth()
  create(@Body() createPageDto: CreatePageDto) {
    return this.pagesService.create(createPageDto);
  }

  @Public()
  @Get()
  findAll() {
    return this.pagesService.findAll();
  }

  @Public()
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.pagesService.findOne({
      where: { id },
    });
  }

  @Public()
  @Get('name/:name')
  findOneByName(@Param('name') name: string) {
    return this.pagesService.findOne({
      where: { name },
    });
  }

  @Public()
  @Get('file/:id')
  async findOneFile(@Param('id', ParseIntPipe) id: number) {
    return this.httpService.get((await this.findOne(id)).url, {
      headers: { 'Accept': 'application/json' }
    }).pipe(
        map(response => response.data),
    );
  }

  @Public()
  @Get('file/name/:name')
  async findOneFileByName(@Param('name') name: string) {
    return this.httpService.get((await this.findOneByName(name)).url, {
      headers: { 'Accept': 'application/json' }
    }).pipe(
        map(response => response.data),
    );
  }

  @Patch(':id')
  @ApiBearerAuth()
  update(@Param('id', ParseIntPipe) id: number, @Body() updatePageDto: UpdatePageDto) {
    return this.pagesService.update(id, updatePageDto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.pagesService.remove(id);
  }
}
