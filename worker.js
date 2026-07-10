export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // /proxy?url=https://kabutan.jp/... → 株探へ代理アクセス
    if (url.pathname === '/proxy') {
      const target = url.searchParams.get('url');
      if (!target || !target.startsWith('https://kabutan.jp/')) {
        return new Response('kabutan.jp URL only', { status: 400 });
      }
      try {
        const res = await fetch(target, {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7',
            'Referer': 'https://kabutan.jp/',
          },
        });
        const body = await res.arrayBuffer();
        return new Response(body, {
          status: res.status,
          headers: {
            'Content-Type': res.headers.get('Content-Type') || 'text/html; charset=utf-8',
            'Access-Control-Allow-Origin': '*',
            'X-Proxy-Status': String(res.status),
          },
        });
      } catch (e) {
        return new Response('Fetch error: ' + e.message, { status: 502 });
      }
    }

    // それ以外は静的ファイルを返す
    return env.ASSETS.fetch(request);
  },
};