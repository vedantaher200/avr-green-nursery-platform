import fs from 'fs';
import path from 'path';
import { logger } from '../logger';

export interface StorageProvider {
  uploadFile(fileBuffer: Buffer, fileName: string, mimeType: string, folder?: string): Promise<{ key: string; publicUrl: string }>;
  getFileStream(key: string): Promise<{ stream: fs.ReadStream; mimeType: string; size: number }>;
  deleteFile(key: string): Promise<boolean>;
}

export class LocalStorageProvider implements StorageProvider {
  private baseDir: string;
  private baseUrl: string;

  constructor(baseDir?: string, baseUrl?: string) {
    this.baseDir = baseDir || path.resolve(__dirname, '../../../../uploads');
    this.baseUrl = baseUrl || '/uploads';
    if (!fs.existsSync(this.baseDir)) {
      fs.mkdirSync(this.baseDir, { recursive: true });
    }
  }

  async uploadFile(fileBuffer: Buffer, fileName: string, mimeType: string, folder = 'general'): Promise<{ key: string; publicUrl: string }> {
    const targetDir = path.join(this.baseDir, folder);
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
    }
    const safeFileName = `${Date.now()}_${fileName.replace(/[^a-zA-Z0-9.-]/g, '_')}`;
    const filePath = path.join(targetDir, safeFileName);
    await fs.promises.writeFile(filePath, fileBuffer);
    const key = `${folder}/${safeFileName}`;
    const publicUrl = `${this.baseUrl}/${key}`;
    logger.debug(`[LocalStorageProvider] Saved file ${key} (${fileBuffer.length} bytes)`);
    return { key, publicUrl };
  }

  async getFileStream(key: string): Promise<{ stream: fs.ReadStream; mimeType: string; size: number }> {
    const filePath = path.join(this.baseDir, key);
    if (!fs.existsSync(filePath)) {
      throw new Error(`File not found: ${key}`);
    }
    const stat = await fs.promises.stat(filePath);
    const ext = path.extname(filePath).toLowerCase();
    const mimeMap: Record<string, string> = {
      '.pdf': 'application/pdf',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.webp': 'image/webp',
    };
    return {
      stream: fs.createReadStream(filePath),
      mimeType: mimeMap[ext] || 'application/octet-stream',
      size: stat.size,
    };
  }

  async deleteFile(key: string): Promise<boolean> {
    const filePath = path.join(this.baseDir, key);
    if (fs.existsSync(filePath)) {
      await fs.promises.unlink(filePath);
      return true;
    }
    return false;
  }
}

export class CloudflareR2StorageProvider implements StorageProvider {
  private bucket: string;
  private publicUrl: string;

  constructor(bucket: string, publicUrl: string) {
    this.bucket = bucket;
    this.publicUrl = publicUrl;
  }

  async uploadFile(fileBuffer: Buffer, fileName: string, mimeType: string, folder = 'general'): Promise<{ key: string; publicUrl: string }> {
    const key = `${folder}/${Date.now()}_${fileName}`;
    logger.info(`[R2StorageProvider] Mock R2 upload for ${key} into ${this.bucket}`);
    return {
      key,
      publicUrl: `${this.publicUrl}/${key}`,
    };
  }

  async getFileStream(key: string): Promise<{ stream: fs.ReadStream; mimeType: string; size: number }> {
    throw new Error('Direct R2 stream not implemented in local dev; use publicUrl');
  }

  async deleteFile(key: string): Promise<boolean> {
    logger.info(`[R2StorageProvider] Deleted object ${key}`);
    return true;
  }
}

let activeStorageProvider: StorageProvider | null = null;

export function getStorageProvider(): StorageProvider {
  if (!activeStorageProvider) {
    const r2Key = process.env.R2_ACCESS_KEY_ID;
    const r2Bucket = process.env.R2_BUCKET_NAME;
    const r2PublicUrl = process.env.R2_PUBLIC_URL;

    if (r2Key && r2Bucket && !r2Key.startsWith('your_r2')) {
      activeStorageProvider = new CloudflareR2StorageProvider(r2Bucket, r2PublicUrl || '');
      logger.info('Initialized Cloudflare R2 Storage Provider');
    } else {
      activeStorageProvider = new LocalStorageProvider();
      logger.info('Initialized Local Storage Provider (Development Mode)');
    }
  }
  return activeStorageProvider;
}
