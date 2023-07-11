import { Controller, Get, Post, Body, Patch, Param, Delete, ParseIntPipe } from '@nestjs/common';
import { PagesService } from './pages.service';
import { CreatePageDto } from './dto/create-page.dto';
import { UpdatePageDto } from './dto/update-page.dto';
import { Public } from '../auth/public.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('pages')
@Controller('pages')
export class PagesController {
  constructor(private readonly pagesService: PagesService) {}

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
      where: { path: name },
    });
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
