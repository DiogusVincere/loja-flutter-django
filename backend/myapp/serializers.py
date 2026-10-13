from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Product, Order
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework import serializers

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = "__all__"


class OrderSerializer(serializers.ModelSerializer):
    # user será preenchido no view (read-only)
    user = serializers.ReadOnlyField(source='user.id')

    class Meta:
        model = Order
        fields = "__all__"
        read_only_fields = ("user", "created_at", "updated_at", "id")

    def validate(self, data):
        # validações simples: subtotal + delivery_fee = total, items não vazio etc.
        items = data.get("items")
        if not items or not isinstance(items, list):
            raise serializers.ValidationError({"items": "A lista de items é obrigatória."})

        subtotal = data.get("subtotal")
        delivery_fee = data.get("delivery_fee")
        total = data.get("total")
        if subtotal is None or delivery_fee is None or total is None:
            raise serializers.ValidationError("subtotal, delivery_fee e total são obrigatórios.")

        # opcional: validar total == subtotal + delivery_fee
        try:
            if round(float(subtotal) + float(delivery_fee), 2) != round(float(total), 2):
                raise serializers.ValidationError("O total deve ser subtotal + delivery_fee.")
        except Exception:
            pass

        return data


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "username", "email", "first_name")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    name = serializers.CharField(source="first_name")

    class Meta:
        model = User
        fields = ("id", "name", "email", "password")

    def create(self, validated_data):
        first_name = validated_data.pop("first_name", "")
        email = validated_data.get("email")
        password = validated_data.pop("password")
        # usamos email como username
        user = User.objects.create(username=email, email=email, first_name=first_name)
        user.set_password(password)
        user.save()
        return user

class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    # Agora o campo principal é "username"
    username_field = "username"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Campo esperado pelo Flutter
        self.fields['username'] = serializers.CharField()
        self.fields['password'] = serializers.CharField()

    def validate(self, attrs):
        username = attrs.get("username")
        password = attrs.get("password")

        if not username:
            raise serializers.ValidationError({"username": "Campo obrigatório."})
        if not password:
            raise serializers.ValidationError({"password": "Campo obrigatório."})

        # Busca usuário
        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            raise serializers.ValidationError({"detail": "Credenciais inválidas."})

        # Verifica a senha
        if not user.check_password(password):
            raise serializers.ValidationError({"detail": "Credenciais inválidas."})

        # SimpleJWT exige username internamente
        attrs["username"] = user.username

        data = super().validate(attrs)

        data["id"] = user.id
        data["email"] = user.email
        data["name"] = user.first_name
        data["token"] = data["access"]

        return data