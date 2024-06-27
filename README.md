# asset-packagist-mirror

## packages.json

> https://cdn.asset-packagist.org/packages.json

```bash
# 获取最新 sha256 下载目录文件
curl -o provider-latest.json https://cdn.asset-packagist.org/p/provider-latest/94585b5705a081d96cc2b942b791c3bb94d8ba32f5f962b721819c11f6937b27.json
```

## p/bower-asset

```bash
# "bower-asset/inputmask"
curl -o ./p/bower-asset/inputmask/d841920811fe452bd740e726c3ce4865dbfdedc280b98886bbd1c6a1bf76be04.json https://cdn.asset-packagist.org/p/bower-asset/inputmask/d841920811fe452bd740e726c3ce4865dbfdedc280b98886bbd1c6a1bf76be04.json

# "bower-asset/bootstrap"
curl -o ./p/bower-asset/bootstrap/192e6dc1439f0d4312cfb1a7606de33d07726545303986568cf7d98f8decee21.json https://cdn.asset-packagist.org/p/bower-asset/bootstrap/192e6dc1439f0d4312cfb1a7606de33d07726545303986568cf7d98f8decee21.json

# "bower-asset/jquery"
curl -o ./p/bower-asset/jquery/fdbece4f23204144ccdcf96e823ec62d75c88e75d92b3a75f94143041baf111e.json https://cdn.asset-packagist.org/p/bower-asset/jquery/fdbece4f23204144ccdcf96e823ec62d75c88e75d92b3a75f94143041baf111e.json

# "bower-asset/punycode"
curl -o ./p/bower-asset/punycode/727dbda3336fde65e173a7396eb70b2fab64e54d1ab1a3bb8b9faaf13b9296d3.json https://cdn.asset-packagist.org/p/bower-asset/punycode/727dbda3336fde65e173a7396eb70b2fab64e54d1ab1a3bb8b9faaf13b9296d3.json

# "bower-asset/yii2-pjax"
curl -o ./p/bower-asset/yii2-pjax/eb109d1834b209b83d67eb90e4e98d7b98546b66a2c17de95a4b5a072ca8d431.json https://cdn.asset-packagist.org/p/bower-asset/yii2-pjax/eb109d1834b209b83d67eb90e4e98d7b98546b66a2c17de95a4b5a072ca8d431.json
```

## 本地部署

`providers-url` 进行对应的调整

## conposer.json

```json
    "repositories": [
        {
            "type": "composer",
            "url": "https://raw.githubusercontent.com/imzyf/asset-packagist-mirror/main/",
            "only": ["bower-asset/*"]
        },
        {
            "type": "composer",
            "url": "https://mirrors.tencent.com/composer/"
        },
        {
            "packagist.org": false
        }
    ]
```
