import type { Metadata } from 'next';
import { Archivo, Manrope } from 'next/font/google';
import { NextIntlClientProvider, hasLocale } from 'next-intl';
import { setRequestLocale } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/lib/i18n/routing';
import '../globals.css';

// Self-hosted at build time — ARCHITECTURE.md §16.1 (fonts: self-hosted/cache-first).
const archivo = Archivo({ subsets: ['latin', 'latin-ext'], variable: '--font-archivo' });
const manrope = Manrope({ subsets: ['latin', 'latin-ext'], variable: '--font-manrope' });

export const metadata: Metadata = {
  // BRAND-01 is open — `LifeOS` is the repository label, not the shipping name.
  title: 'LifeOS',
  description: 'Strength-training log.',
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  if (!hasLocale(routing.locales, locale)) notFound();

  // Required for static rendering under `output: 'export'`.
  setRequestLocale(locale);

  return (
    <html lang={locale} data-theme="dark" className={`${archivo.variable} ${manrope.variable}`}>
      <body>
        <NextIntlClientProvider>{children}</NextIntlClientProvider>
      </body>
    </html>
  );
}
