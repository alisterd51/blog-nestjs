import { Injectable } from '@nestjs/common';
import { CreatePageDto } from './dto/create-page.dto';
import { UpdatePageDto } from './dto/update-page.dto';
import { Page } from './entities/page.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { DeleteResult, FindOneOptions, Repository } from 'typeorm';

@Injectable()
export class PagesService {
  constructor(
    @InjectRepository(Page)
    private pagesRepository: Repository<Page>,
  ) {}

  create(createPageDto: CreatePageDto) {
    const page = this.pagesRepository.create(createPageDto);
    return this.pagesRepository.save(page);
  }

  findAll(): Promise<Page[]> {
    return this.pagesRepository.find();
  }

  findOne(where: FindOneOptions<Page>): Promise<Page | null> {
    return this.pagesRepository.findOne(where);
  }

  update(id: number, updatePageDto: UpdatePageDto) {
    return this.pagesRepository.update({ id }, updatePageDto);
  }

  remove(id: number): Promise<DeleteResult> {
    return this.pagesRepository.delete(id);
  }
}
