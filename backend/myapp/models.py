from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone # Importação mantida, mas não utilizada nos campos corrigidos

class Product(models.Model):
    CATEGORY_CHOICES = [
        ("Lanches", "Lanches"),
        ("Pizzas", "Pizzas"),
        ("Bebidas", "Bebidas"),
        ("Sobremesas", "Sobremesas"),
    ]

    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    image_url = models.URLField(null=True, blank=True)
    is_available = models.BooleanField(default=True)
    # CORREÇÃO: Removida a repetição do argumento 'auto_now_add=True'
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

# ---

class Order(models.Model):
    STATUS_CHOICES = [
        ("pending", "Pendente"),
        ("confirmed", "Confirmado"),
        ("preparing", "Em Preparo"),
        ("out_for_delivery", "Saiu para Entrega"),
        ("delivered", "Entregue"),
        ("cancelled", "Cancelado"),
    ]

    # user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="orders") 
    # ^ Já estava correto
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="orders")
    
    # Mantemos a estrutura que o Flutter envia (items com produto embutido) como JSONField:
    items = models.JSONField()
    # Address também como JSON (perfeito para usar AddressModel.toJson() do Flutter)
    address = models.JSONField()
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    payment_method = models.CharField(max_length=50, null=True, blank=True)
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Pedido #{self.id} - {self.user.email}"