# Loja Flutter + Django

App de pedidos de lanchonete ("Mange Eats") feito em Flutter, com catálogo, carrinho e checkout, falando com uma API Django REST autenticada por JWT.

## Funcionalidades

Lidas do código do app (`mobile/lib`) e da API (`backend/myapp`):

- **Login e cadastro** com nome, e-mail, senha e telefone opcional. A sessão fica guardada no aparelho (`shared_preferences`) e há "Sair" no menu.
- **Catálogo** de produtos vindo da API, filtrado por categoria: Lanches, Pizzas, Bebidas e Sobremesas.
- **Carrinho** com quantidade por item, remoção e subtotal. Frete de R$ 5,00, grátis em compras a partir de R$ 100,00.
- **Endereço de entrega pelo CEP**: o app consulta o ViaCEP, preenche rua, bairro, cidade e UF, e pede o número.
- **Checkout** com resumo dos itens, forma de pagamento (Dinheiro, Cartão de Crédito, Cartão de Débito ou PIX) e confirmação do pedido na API.
- **API REST** com produtos (leitura pública, filtro `?category=`), pedidos do usuário autenticado (`items` e `address` em JSON, status Pendente → Entregue), login e registro que devolvem o token JWT, e o admin do Django.
- **Dados de demonstração**: `python manage.py seed_demo` cria o usuário `demo` e oito produtos.

## Arquitetura

```
 app Flutter (Provider)  ──HTTP/JSON + Bearer JWT──▶  API Django REST (DRF + SimpleJWT)  ──▶  SQLite
        │
        └──────────────── https://viacep.com.br ─────▶  consulta de CEP (direto do app)
```

| Método | Rota                    | Acesso        | O que faz                                    |
|--------|-------------------------|---------------|----------------------------------------------|
| POST   | `/api/auth/register/`   | público       | cria usuário (`name`, `email`, `password`) e devolve `token` |
| POST   | `/api/auth/login/`      | público       | `username` + `password` → `access`, `refresh`, `token`, `id`, `email`, `name` |
| GET    | `/api/products/`        | público       | lista produtos; aceita `?category=Pizzas`    |
| GET    | `/api/orders/`          | autenticado   | pedidos do usuário logado                    |
| POST   | `/api/orders/`          | autenticado   | cria pedido (`items`, `address`, `subtotal`, `delivery_fee`, `total`, `payment_method`) |
| —      | `/admin/`               | superusuário  | admin do Django                              |

O registro usa o e-mail como `username`; por isso o login do app envia o e-mail no campo `username`.

## Estrutura

```
mobile/                 app Flutter (histórico preservado do repositório original)
  lib/models/           produto, item do carrinho, endereço, pedido, usuário
  lib/providers/        AuthProvider, CartProvider, ProductsProvider
  lib/screens/          login, cadastro, início, carrinho, checkout
  lib/services/         ApiService (API Django) e ViaCepService
  lib/utils/            constants.dart (URL da API, taxas, textos) e tema
backend/                API Django (sem histórico: o original trazia banco e chave secreta)
  core/                 settings.py lê tudo do ambiente; urls.py monta /api/ e /admin/
  myapp/                models, serializers, views, urls e o comando seed_demo
  requirements.txt      Django, DRF, SimpleJWT, django-cors-headers, gunicorn
  .env.example          variáveis de ambiente documentadas
render.yaml             blueprint do Render para publicar a API
```

## Como rodar

### Pré-requisitos

- Python 3.10 ou mais novo (a API usa Django 5.2).
- Flutter estável com Dart SDK 3.9 ou mais novo (`flutter doctor` sem erros para a plataforma escolhida).

### 1. API (backend)

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate      Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
```

As configurações vêm de variáveis de ambiente (ver `backend/.env.example`). O projeto não carrega `.env` sozinho: exporte as variáveis no terminal ou use a ferramenta de sua preferência. Para desenvolver, basta ligar o DEBUG:

```bash
# Windows (PowerShell):  $env:DEBUG = "True"
# Linux/macOS:           export DEBUG=True
python manage.py migrate
python manage.py seed_demo
python manage.py runserver 0.0.0.0:8000
```

Sem `SECRET_KEY` definida, o Django gera uma chave aleatória a cada inicialização (os tokens JWT deixam de valer quando o servidor reinicia). Em produção defina `SECRET_KEY`, `DEBUG=False` e `ALLOWED_HOSTS`.

### 2. App (mobile)

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

- `10.0.2.2` é o computador visto de dentro do emulador Android e já é o valor padrão; o `--dart-define` só é necessário para apontar para outro lugar.
- Celular físico na mesma rede: `--dart-define=API_URL=http://IP_DO_COMPUTADOR:8000/api`.
- Flutter Web: `--dart-define=API_URL=http://localhost:8000/api` (a API já responde CORS para qualquer origem por padrão).
- API publicada: `--dart-define=API_URL=https://SEU-SERVICO.onrender.com/api`.

### 3. Publicar a API no Render

O `render.yaml` da raiz cria um web service Python: instala `backend/requirements.txt` e sobe com `migrate` + `seed_demo` + `gunicorn`. A `SECRET_KEY` é gerada pelo Render, `DEBUG=False` e `ALLOWED_HOSTS=.onrender.com`. O banco é SQLite no disco do serviço — no plano gratuito ele é recriado a cada deploy, e o `seed_demo` repõe o usuário e os produtos.

## Usuário de demonstração

| Campo | Valor |
|-------|-------|
| usuário (digite no campo "Email" do app) | `demo` |
| senha | `demo1234` |

Credenciais públicas de propósito, só para testar. Para um administrador, use `python manage.py createsuperuser`.

## Demonstração

<!-- prints: adicionar -->

## Licença

MIT — ver [LICENSE](LICENSE).
