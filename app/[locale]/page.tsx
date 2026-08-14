import { setRequestLocale } from 'next-intl/server';
import { getTranslations } from 'next-intl/server';

export default async function Home({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations('nav');

  return (
    <main style={{ padding: 'var(--space-4, 16px)' }}>
      <h1>{t('home')}</h1>
      <p className="eyebrow">M0 walking skeleton</p>
    </main>
  );
}
