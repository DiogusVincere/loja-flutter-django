"""
Cria o usuário de demonstração e um cardápio de exemplo.

Pode rodar quantas vezes quiser (idempotente): o usuário é criado uma vez e tem
a senha reposta; os produtos são localizados pelo nome e atualizados.
"""
from decimal import Decimal

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from myapp.models import Product

# Credenciais públicas de propósito: servem só para testar o app.
USUARIO_DEMO = "demo"
SENHA_DEMO = "demo1234"
EMAIL_DEMO = "demo@exemplo.com"

PRODUTOS = [
    {
        "name": "X-Burger Clássico",
        "description": "Hambúrguer artesanal, queijo, alface, tomate e molho especial",
        "price": Decimal("25.90"),
        "category": "Lanches",
    },
    {
        "name": "X-Bacon",
        "description": "Hambúrguer, bacon crocante, queijo cheddar e molho barbecue",
        "price": Decimal("28.90"),
        "category": "Lanches",
    },
    {
        "name": "Pizza Margherita",
        "description": "Molho de tomate, mussarela, manjericão fresco e azeite",
        "price": Decimal("45.90"),
        "category": "Pizzas",
    },
    {
        "name": "Pizza Calabresa",
        "description": "Molho de tomate, mussarela, calabresa fatiada e cebola",
        "price": Decimal("48.90"),
        "category": "Pizzas",
    },
    {
        "name": "Refrigerante Lata 350ml",
        "description": "Refrigerante gelado, sabores cola ou guaraná",
        "price": Decimal("6.90"),
        "category": "Bebidas",
    },
    {
        "name": "Suco Natural de Laranja 500ml",
        "description": "Suco de laranja espremido na hora",
        "price": Decimal("12.90"),
        "category": "Bebidas",
    },
    {
        "name": "Brownie com Sorvete",
        "description": "Brownie de chocolate quente com bola de sorvete de baunilha",
        "price": Decimal("18.90"),
        "category": "Sobremesas",
    },
    {
        "name": "Pudim de Leite",
        "description": "Pudim caseiro de leite condensado com calda de caramelo",
        "price": Decimal("15.90"),
        "category": "Sobremesas",
    },
]


class Command(BaseCommand):
    help = "Cria o usuário demo (senha demo1234) e produtos de exemplo. Idempotente."

    def handle(self, *args, **options):
        usuario, criado = User.objects.get_or_create(
            username=USUARIO_DEMO,
            defaults={"email": EMAIL_DEMO, "first_name": "Demo"},
        )
        # A senha é reposta sempre, para o login de demonstração nunca quebrar.
        usuario.set_password(SENHA_DEMO)
        usuario.save(update_fields=["password"])
        situacao = "criado" if criado else "já existia"
        self.stdout.write(f"Usuário {USUARIO_DEMO}: {situacao} (senha reposta).")

        novos = 0
        for dados in PRODUTOS:
            _, foi_criado = Product.objects.update_or_create(
                name=dados["name"],
                defaults={**dados, "is_available": True},
            )
            novos += int(foi_criado)
        self.stdout.write(
            f"Produtos: {novos} criado(s), {len(PRODUTOS) - novos} atualizado(s), "
            f"{Product.objects.count()} no total."
        )
