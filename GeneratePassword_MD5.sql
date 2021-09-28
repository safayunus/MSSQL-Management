-- Generate Random Password 
DECLARE @char CHAR = ''
DECLARE @charI INT = 0
DECLARE @password VARCHAR(50) = ''
DECLARE @MD5 VARCHAR(40)=''
DECLARE @len INT = 6 -- Length of Password
WHILE @len > 0
BEGIN
SET @charI = ROUND(RAND()*100,0)
SET @char = CHAR(@charI)
 
IF @charI > 48 AND @charI <122 
BEGIN
SET @password += @char
SET @len = @len - 1
END
END
SET @MD5= CONVERT(VARCHAR(32), HashBytes('MD5',  @password), 2) 
SELECT @password as Password --Password
SELECT @MD5 as MD5 --
