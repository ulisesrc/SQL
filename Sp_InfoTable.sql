USE MASTER
GO

IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE Name = 'Sp_InfoTable' AND TYPE = 'P')
   DROP PROCEDURE Sp_InfoTable
GO

CREATE PROCEDURE Sp_InfoTable
	@Columna		NVARCHAR(150)	= '',   
	@Tabla			NVARCHAR(150)	= '',	
	@BaseDatos    	NVARCHAR(150)	= '',	
	@Constraint		SMALLINT		= 0, 	
	@OrderBy      	BIT				= 0		
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON 

	DECLARE @_BaseDatos  VARCHAR(150),
			@_Script	 NVARCHAR(MAX),
			@_Parameter  NVARCHAR(MAX)

	IF @BaseDatos = ''
	   SET @_BaseDatos = 'MASTER' --> Indicar un nombre de Base Datos Default
	ELSE
	   SET @_BaseDatos = @BaseDatos
	
	IF @Constraint < 0 OR @Constraint > 4
	   SET @Constraint = 0

	SET @_Parameter = N'@TableName   NVARCHAR(150),
	                    @ColumnName  NVARCHAR(150), 
						@Constraint  SMALLINT'

	SET @_Script	= N'DECLARE @_Campo CHAR(2)
					          
						SET @_Campo = ' + '''' + '''' + '
									  SELECT Tabla, Columna, Tipo, [Tamaño], IsIdentity, Permite_Nulos, ValorDefault, PrimaryKey, ForeignKey, Descripcion
										FROM (SELECT Tabla,         Columna,    Tipo,       [Tamaño], 
													 Permite_Nulos, IsIdentity, PrimaryKey, ForeignKey, 
													 Descripcion,   ValorDefault, 
													 CASE WHEN ' + CAST(@OrderBy AS VARCHAR) + ' = 1 THEN 
															   (SELECT Ordinal_Position 
																  FROM ' + @_BaseDatos + '.INFORMATION_SCHEMA.COLUMNS C2 
																 WHERE Tb2.Tabla = C2.TABLE_NAME AND Tb2.Columna = C2.COLUMN_NAME)
														  ELSE 0 
													 END AS OrderBY
												FROM (SELECT Tabla,    Columna,       Tipo, 
												             [Tamaño], Permite_Nulos, IsIdentity, ValorDefault,
						                                     SUM(PrimaryKey) AS PrimaryKey, 
						                                     SUM(ForeignKey) AS ForeignKey,						 
						                                     ISNULL((SELECT Info1.Value
							                                           FROM ' + @_BaseDatos + '.SYS.TABLES Tb1
							                                          INNER JOIN ' + @_BaseDatos + '.SYS.COLUMNS			       Col1  ON Col1.Object_Id = Tb1.Object_Id
							                                          INNER JOIN ' + @_BaseDatos + '.SYS.EXTENDED_PROPERTIES Info1 ON Info1.Major_Id = Tb1.Object_Id AND Info1.Minor_Id = Col1.Column_Id
							                                          WHERE Info1.Name = ' + '''' + 'MS_Description' + '''' + '
																		AND Tb1.Name   = Tb.Tabla
																		AND Col1.Name  = Tb.Columna), ' + '''' + '''' + ') AS Descripcion						    
													    FROM (SELECT C.TABLE_NAME		AS Tabla, 
																	 C.COLUMN_NAME      AS Columna, 
																	 UPPER(C.DATA_TYPE)	AS Tipo,  
																	 ISNULL(SUBSTRING(C.COLUMN_DEFAULT, 2, LEN(C.COLUMN_DEFAULT) - 2), ' + '''''' + ') AS ValorDefault, 
																	 CASE WHEN ISNULL(C.CHARACTER_MAXIMUM_LENGTH, 0) > 0 THEN 
																			   CONVERT(VARCHAR, C.CHARACTER_MAXIMUM_LENGTH)
																		  WHEN C.DATA_TYPE = ' + '''' + 'NUMERIC' + '''' + ' 
																		    OR C.DATA_TYPE = ' + '''' + 'DECIMAL' + '''' + ' THEN ' +
																			'''' +  '(' + '''' + '+ CAST(C.NUMERIC_PRECISION AS VARCHAR) + ' + '''' + ',' + '''' + '+ CAST(C.NUMERIC_SCALE AS VARCHAR) +' + '''' + ')' + '''' + '
																		  ELSE ' + '''''' + '
																	 END AS [Tamaño], 
																	 CASE WHEN C.IS_NULLABLE = ' + '''' + 'NO' + '''' + ' THEN ' + '''' + 'No' + '''' + ' 
																		  ELSE ' + '''' + 'Si' + '''' + '
																     END AS Permite_Nulos,
																	 CASE LEFT(K.CONSTRAINT_NAME, 2) WHEN ' + '''' + 'PK' + '''' + ' THEN 1 ELSE 0 END AS PrimaryKey,
																	 CASE LEFT(K.CONSTRAINT_NAME, 2) WHEN ' + '''' + 'FK' + '''' + ' THEN 1 ELSE 0 END AS ForeignKey, 
																	 CASE WHEN COLUMNPROPERTY(OBJECT_ID(C.TABLE_NAME), C.COLUMN_NAME, ' + '''' + 'IsIdentity' + '''' + ') = 1 THEN ' + '''' + 'SI' + '''' + '
																	      ELSE ' + '''''' + '
																	 END AS IsIdentity																	 
																FROM ' + @_BaseDatos + '.INFORMATION_SCHEMA.COLUMNS C
																LEFT OUTER JOIN ' + @_BaseDatos + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE K ON K.TABLE_NAME = C.TABLE_NAME AND K.COLUMN_NAME = C.COLUMN_NAME
															   WHERE (C.Table_Name  LIKE @TableName  OR  @TableName  = @_Campo) 
																 AND (C.Column_Name LIKE @ColumnName OR  @ColumnName = @_Campo)
																 AND (		@Constraint = 0 OR (@Constraint   = 1 AND  LEFT(K.CONSTRAINT_NAME, 2) = ' + '''' + 'PK' + '''' + ')
																		OR (@Constraint   = 2 AND  LEFT(K.CONSTRAINT_NAME, 2) = ' + '''' + 'FK' + '''' + ')
																		OR (@Constraint   = 3 AND (LEFT(K.CONSTRAINT_NAME, 2) = ' + '''' + 'PK' + '''' + ' OR LEFT(K.CONSTRAINT_NAME, 2) = ' + '''' + 'FK' + '''' + '))
																	  )
													         ) Tb
					                                   GROUP BY Tabla, Columna, Tipo, [Tamaño], Permite_Nulos, IsIdentity, ValorDefault
					                                 ) Tb2
				                             ) Tb3
			                           ORDER BY Tabla, OrderBy ASC, Columna'

	EXEC SP_EXECUTESQL @_Script, @_Parameter, @Tabla, @Columna, @Constraint
END