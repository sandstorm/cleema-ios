# Universal links

> **NOTE** Is this doc still relevant?

## AASA

Specify paths to open the app only for links it is capable of.

```
{
	"applinks": {
		"apps": [],
		"details": [{
				"appID": "9ZRAJV4AQQ.de.cleema.Cleema-development",
				"paths": ["/invites/*"]
			},
			{
				"appID": "9ZRAJV4AQQ.de.cleema.Cleema-beta",
				"paths": ["/invites/*"]
			},
			{
				"appID": "9ZRAJV4AQQ.de.cleema.Cleema",
				"paths": ["/invites/*"]
			}
		]
	}
}
```

Place on server in /.well-known/apple-app-site-association

Define application/json as mime type for this file in nginx

```
location ^~ /.well-known/apple-app-site-association {
	default_type application/json;
}
```

Restart nginx
> service nginx restart

## Entitlements

To prevent caching use mode=developer. Disable in production to make full SSL-checking available.

```
<dict>
	<key>com.apple.developer.associated-domains</key>
	<array>
		<string>applinks:cleema.app?mode=developer</string>
	</array>
</dict>
```

## Swift

Adds onOpenULR modifier in scene root

```
WindowGroup {
	ContentView()
	.onOpenURL { url in
		print(url)
	}
}
```
