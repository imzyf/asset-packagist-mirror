# asset-packagist-mirror

- https://asset-packagist.org/packages.json
- https://asset-packagist.org/p/provider-latest/06008b6860ccabd7764ad9b5152cb52bcc74e47aa456e94186a5725faaa3b3ee.json
- https://cdn.asset-packagist.org/p/provider-latest/06008b6860ccabd7764ad9b5152cb52bcc74e47aa456e94186a5725faaa3b3ee.json

```bash
curl -o asset-index.json https://cdn.asset-packagist.org/p/provider-latest/06008b6860ccabd7764ad9b5152cb52bcc74e47aa456e94186a5725faaa3b3ee.json

# 查找 bower-asset/inputmask 找到 sha256
# 修改 packages.json & 下载文件
curl -o ./p/bower-asset/inputmask/d841920811fe452bd740e726c3ce4865dbfdedc280b98886bbd1c6a1bf76be04.json https://cdn.asset-packagist.org/p/provider-latest/d841920811fe452bd740e726c3ce4865dbfdedc280b98886bbd1c6a1bf76be04.json

# "bower-asset/bootstrap"
curl -o ./p/bower-asset/bootstrap/192e6dc1439f0d4312cfb1a7606de33d07726545303986568cf7d98f8decee21.json https://cdn.asset-packagist.org/p/provider-latest/192e6dc1439f0d4312cfb1a7606de33d07726545303986568cf7d98f8decee21.json

# "bower-asset/jquery"
curl -o ./p/bower-asset/jquery/fdbece4f23204144ccdcf96e823ec62d75c88e75d92b3a75f94143041baf111e.json https://cdn.asset-packagist.org/p/provider-latest/fdbece4f23204144ccdcf96e823ec62d75c88e75d92b3a75f94143041baf111e.json

# "bower-asset/punycode"
curl -o ./p/bower-asset/punycode/727dbda3336fde65e173a7396eb70b2fab64e54d1ab1a3bb8b9faaf13b9296d3.json https://cdn.asset-packagist.org/p/provider-latest/727dbda3336fde65e173a7396eb70b2fab64e54d1ab1a3bb8b9faaf13b9296d3.json

# "bower-asset/yii2-pjax"
curl -o ./p/bower-asset/yii2-pjax/eb109d1834b209b83d67eb90e4e98d7b98546b66a2c17de95a4b5a072ca8d431.json https://cdn.asset-packagist.org/p/provider-latest/eb109d1834b209b83d67eb90e4e98d7b98546b66a2c17de95a4b5a072ca8d431.json
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
