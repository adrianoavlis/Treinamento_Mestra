/*

Mostre a soma dos sal�rios de toda a companhia, sal�rio m�dio, sal�rio m�nimo e o sal�rio m�ximo.

*/

select sum(VRSPA),avg(VRSPA), min(VRSPA), max(VRSPA) from CTB_HISALARIOS


/*

Qual � o primeiro sobrenome em ordem alfab�tica?

*/

WITH NameParts AS (
    SELECT 
        NMPAR,
        CASE 
            WHEN CHARINDEX(' ', NMPAR) > 0 
            THEN SUBSTRING(NMPAR, CHARINDEX(' ', NMPAR) + 1, LEN(NMPAR))
            ELSE NMPAR
        END AS LastName
    FROM PAR_PARTICIPANTES
)
SELECT TOP 1 LastName
FROM NameParts
ORDER BY LastName ASC
go

select NMPAR from par_participantes order by NMPAR

sp_help PAR_PARTICIPANTES
