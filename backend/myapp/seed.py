from django.contrib.auth.models import User
from myapp.models import Product

def run():
    if not User.objects.filter(username="admin").exists():
        User.objects.create_superuser("admin", "admin@example.com", "admin123")

    Product.objects.all().delete()

    dados = [
        {"name":"X-Burger Clássico","description":"Hambúrguer artesanal, queijo, alface, tomate e molho especial","price":25.90,"category":"Lanches"},
        {"name":"X-Bacon","description":"Hambúrguer, bacon crocante, queijo cheddar e molho barbecue","price":28.90,"category":"Lanches"},
        {"name":"X-Egg","description":"Hambúrguer, ovo frito, queijo, presunto e maionese","price":27.90,"category":"Lanches"},
        {"name":"X-Salada Premium","description":"Hambúrguer grelhado, alface, tomate, cebola roxa e molho vinagrete","price":29.90,"category":"Lanches"},
        {"name":"Chicken Burger","description":"Filé de frango empanado, queijo, alface e maionese especial","price":26.90,"category":"Lanches"},
        {"name":"Veggie Burger","description":"Hambúrguer de grão de bico, queijo vegano, rúcula e tomate seco","price":27.90,"category":"Lanches"},
        {"name":"Pizza Margherita","description":"Molho de tomate, mussarela, manjericão fresco e azeite","price":45.90,"category":"Pizzas"},
        {"name":"Pizza Calabresa","description":"Molho de tomate, mussarela, calabresa fatiada e cebola","price":48.90,"category":"Pizzas"},
        {"name":"Pizza Portuguesa","description":"Presunto, mussarela, ovos, cebola, azeitonas e orégano","price":52.90,"category":"Pizzas"},
        {"name":"Pizza Quatro Queijos","description":"Mussarela, parmesão, gorgonzola e provolone","price":54.90,"category":"Pizzas"},
        {"name":"Pizza Frango com Catupiry","description":"Frango desfiado, catupiry, milho e azeitonas","price":51.90,"category":"Pizzas"},
        {"name":"Pizza Pepperoni","description":"Molho de tomate, mussarela e fatias generosas de pepperoni","price":49.90,"category":"Pizzas"},
        {"name":"Coca-Cola Lata 350ml","description":"Refrigerante de cola gelado","price":6.90,"category":"Bebidas"},
        {"name":"Guaraná Antarctica Lata 350ml","description":"Refrigerante de guaraná","price":6.90,"category":"Bebidas"},
        {"name":"Suco Natural de Laranja 500ml","description":"Suco natural de laranja espremido na hora","price":12.90,"category":"Bebidas"},
        {"name":"Água Mineral 500ml","description":"Água mineral sem gás","price":4.50,"category":"Bebidas"},
        {"name":"Brownie com Sorvete","description":"Brownie de chocolate quente com bola de sorvete de baunilha","price":18.90,"category":"Sobremesas"},
        {"name":"Petit Gateau","description":"Bolinho de chocolate com recheio cremoso e sorvete","price":22.90,"category":"Sobremesas"},
        {"name":"Pudim de Leite","description":"Pudim caseiro de leite condensado com calda de caramelo","price":15.90,"category":"Sobremesas"},
    ]

    for item in dados:
        Product.objects.create(**item)

    print(f"✔ {Product.objects.count()} produtos criados")
