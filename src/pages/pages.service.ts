import { Injectable } from '@nestjs/common';
import { CreatePageDto } from './dto/create-page.dto';
import { UpdatePageDto } from './dto/update-page.dto';
import { Page } from './entities/page.entity';

@Injectable()
export class PagesService {
  private readonly pages: Page[] = [
    {
      id: 0,
      title: 'Création du présent site',
      summary: 'Voici le premier article : La création de ce blog ! Du coup, je vais écrire ici toutes les étapes qui ont mené au blog tel qu\'il est aujourd\'hui.',
      url: 'https://cdn.anclarma.fr/articles/articles/blog-angular.md',
      path: 'blog-angular'
    },
    {
      id: 1,
      title: 'Le futur de la réalité virtuelle',
      summary: 'La réalité virtuelle (RV) est un domaine en constante évolution de la technologie qui offre des expériences immersives captivantes.',
      url: 'https://cdn.anclarma.fr/articles/articles/vr-unparalleled-immersion.md',
      path: 'vr-unparalleled-immersion'
    },
    {
      id: 2,
      title: 'test',
      summary: 'summary',
      url: 'https://cdn.anclarma.fr/articles/articles/test.md',
      path: 'test'
    },
    {
      id: 3,
      title: 'Publicité',
      summary: 'test de google adsense',
      url: 'https://cdn.anclarma.fr/articles/articles/ads.md',
      path: 'ads'
    }
  ];

  create(createPageDto: CreatePageDto) {
    return 'This action adds a new page';
  }

  async findAll(): Promise<Page[]> {
    return this.pages;
  }

  async findOne(id: number): Promise<Page | undefined> {
    return this.pages.find(page => page.id === id);
  }

  update(id: number, updatePageDto: UpdatePageDto) {
    return `This action updates a #${id} page`;
  }

  remove(id: number) {
    return `This action removes a #${id} page`;
  }
}
