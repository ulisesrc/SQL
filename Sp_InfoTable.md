# SP_INFOTABLE

**Permite obtener el diccionario de datos de una Base de datos SQL Server** 

Parámetros:

* Nombre de la columna
* Nombre de la tabla
* Nombre de la base de datos (Se puede colocar una BD por default)
* Bandera que indica el tipo de columnas que desea (por default trae todo los campos)
Valor:
   	 * [0] Todos los campos 
  	 * [1] Primary Key
  	 * [2] Foreign Key	
  	 * [3] Primary Key y/o Foreign Key	
+ Bandera que indica el tipo de orden (por default se ordena alfabéticamente) 
	Valor:
	* [0] Orden alfabetico 
	* [1] se ordena como se introdujeron los elementos a la tabla

**_Nota: Para que el proceso pueda ejecutarse desde cualquier base de datos debe crearse en MASTER_**
 
 ---
**Ejemplos de uso:**


Obtendrá todas las columnas que se llamen 
"Id_Codigo"

```sql
EXEC sp_infotable 'Id_Codigo'        	
```
---
Obtendra todas las tablas que se titulen 'Tb'
```sql
EXEC sp_infotable '', 'Tb'
```
---
Obtendra el diccionario de datos de la base de datos 'BD_Info'
```sql
EXEC sp_infotable '', '', 'BD_Info'
```
---
Obtendra todas las tablas que tengan la columna "Id_Codigo" y sea una llave primaria
```sql
EXEC sp_infotable 'Id_Codigo', '', '', 1	
```
---
Obtendra todas las tablas que tengan la columna "Id_Codigo" y sea llave foránea
```sql
EXEC sp_infotable 'Id_Codigo', '', '', 2
```
---
Obtendra todas las tablas que tengan la columna "Id_Codigo" y que sea llave primaria o forenea
```sql
EXEC sp_infotable 'Id_Codigo', '', '', 3
```
---
Obtendra todas las columnas de la tabla "Tb" y ordenará los elemento como fueron dado de alta
```sql
EXEC sp_infotable '', 'Tb', '', 0, 1		
```
---
Obtendra todas las columnas de la tabla "Tb" y ordenará los elemento alfabéticamente
```sql
EXEC sp_infotable '', 'Tb', '', 0, 0
```
 ---
Si no se sabe el nombre de la columna y/o tabla con precisión se puede utilizar **_'%Nombre%'_**
```sql
EXEC sp_infotable 'Id_%'		
```
Buscara todas las columnas que comiencen con **Id_** 

---
Y por supuesto que se puede combinar los parámetros
```sql
EXEC SP_INFOTABLE '%cliente%', 'Tab%', '', 3 
```
Buscara todas las columnas que contengan la palabra cliente, de todas las tablas que empiecen con TAB donde que sea una llave primaria o una llave foranea 

---

**Si se ejecuta de esta forma obtendra todo el diccionario de datos de la base de datos**

```sql
EXEC SP_INFOTABLE 
```

_Nota: 
En los ejemplos no se coloco el nombre de la base datos debido a que se coloco una Base de Datos por Default (Linea 24 del codigo)_


> **Espero que este codigo te sea de utilidad
¡ Buena Suerte !**