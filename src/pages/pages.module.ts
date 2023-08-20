import { Module } from '@nestjs/common';
import { PagesService } from './pages.service';
import { PagesController } from './pages.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Page } from './entities/page.entity';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [TypeOrmModule.forFeature([Page]), HttpModule],
  controllers: [PagesController],
  providers: [PagesService],
  exports: [TypeOrmModule, PagesService],
})
export class PagesModule {}
