from rest_framework import viewsets, status, permissions
from rest_framework.response import Response
from django.contrib.auth.models import User
from .models import Product, Order
from .serializers import ProductSerializer, OrderSerializer, UserSerializer, RegisterSerializer
from .serializers import EmailTokenObtainPairSerializer

from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.views import APIView

# Helper para gerar token de acesso (access)
def get_access_token_for_user(user):
    refresh = RefreshToken.for_user(user)
    return str(refresh.access_token)


# Custom login wrapper (usa SimpleJWT por baixo)
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer
    

# Registro que retorna token
class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token = get_access_token_for_user(user)
            return Response({
                "id": user.id,
                "email": user.email,
                "name": user.first_name,
                "token": token
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Products
class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by("category", "name")
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        qs = super().get_queryset()
        cat = self.request.query_params.get("category")
        if cat:
            qs = qs.filter(category=cat)
        return qs


# Orders
class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
