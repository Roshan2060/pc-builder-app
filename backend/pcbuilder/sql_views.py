import psycopg2
from psycopg2.extras import RealDictCursor
from django.conf import settings
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import json
from django.db import connection

def get_db_connection():
    return psycopg2.connect(
        host=settings.DATABASES['default']['HOST'],
        database=settings.DATABASES['default']['NAME'],
        user=settings.DATABASES['default']['USER'],
        password=settings.DATABASES['default']['PASSWORD'],
        port=settings.DATABASES['default']['PORT']
    )

@api_view(['GET'])
def get_vendors(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT id, name
                FROM vendors
                ORDER BY name
            """)
            columns = [col[0] for col in cursor.description]
            vendors = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return Response(vendors)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def get_cpus(request):
    try:
        socket_type = request.GET.get('socket_type')
        min_price = request.GET.get('min_price')
        max_price = request.GET.get('max_price')
        vendor_id = request.GET.get('vendor_id')
        query = """
            SELECT c.*, v.name as vendor_name
            FROM cpus c
            JOIN vendors v ON c.vendor_id = v.id
            WHERE c.is_active = TRUE
        """
        params = []
        if socket_type:
            query += " AND c.socket_type = %s"
            params.append(socket_type)
        if min_price:
            query += " AND c.price >= %s"
            params.append(float(min_price))
        if max_price:
            query += " AND c.price <= %s"
            params.append(float(max_price))
        if vendor_id:
            query += " AND c.vendor_id = %s"
            params.append(int(vendor_id))
        query += " ORDER BY c.price"
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            columns = [col[0] for col in cursor.description]
            return Response([dict(zip(columns, row)) for row in cursor.fetchall()])
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


