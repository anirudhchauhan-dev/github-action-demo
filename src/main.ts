import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT);
  console.log('Hellooooooooooooo!!!!');
  console.log(parseInt(process.env.PORT));
  console.log(process.env.DB_NAME);
}
bootstrap();
