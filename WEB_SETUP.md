# Setup Web DailyCatch (Évite Directory Listing)

## 1. **Méthode Recommandée : Flutter Run**
```
cd mobiledailycatch
flutter run -d chrome
```
→ Chrome ouvre auto l'app (localhost:port).

## 2. **Build + Serve (Prod-like)**
```
cd mobiledailycatch
flutter build web --release
cd build/web
python3 -m http.server 8086
```
→ http://localhost:8086/ → App Flutter (index.html).

## ❌ **Évite ça (cause dir listing)**
- Serve depuis `/home/cherif/Bureau/Value Market/last mobile/` (liste .github/mobiledailycatch).
- Ouvre direct `file:///path/mobiledailycatch/web/index.html` (no server).

## **Accès Vendeurs (Partner Dashboard)**
1. App web live.
2. Register/Login as Partner.
3. Nav → /partner-dashboard.

**Testé : Fonctionne sur localhost:8086 !**

