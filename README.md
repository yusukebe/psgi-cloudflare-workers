# psgi-cloudflare-workers

Perl PSGI application, but works on Cloudflare Workers

## Run as Perl PSGI application

```sh
$ plackup app.psgi
```

## Run as Cloudflare Workers

Build:

```
$ npm run build
```

Run dev server, `wranger` is required:

```
$ npm run dev
```

Publish, `wranger` is required:

```
$ npm run publish
```

## Endpoints

`/` => plain text:

```
GET /
```

`/hello` => plain text with query param:

```
GET /hello?name=foo
```

`/api` => JSON:

```
GET /api?message=hello
```

## Related projects

- <https://github.com/cloudflare/perl-worker-hello-world>

## Author

Yusuke Wada <https://github.com/yusukebe>

## LICENSE

MIT
