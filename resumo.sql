BEGIN
    DECLARE
        TYPE cur_type IS REF CURSOR;
        c_arquivos cur_type;
        v_id arquivo.id%TYPE; -- Assumindo que "id" é o nome da coluna
    BEGIN
        -- Abre o cursor para uma consulta específica
        OPEN c_arquivos FOR
            SELECT id
            FROM arquivo
            WHERE situacao = 0
            FOR UPDATE SKIP LOCKED;

        -- Loop através dos registros selecionados
        LOOP
            FETCH c_arquivos INTO v_id; 
            EXIT WHEN c_arquivos%NOTFOUND;
            
            -- Atualiza a situação do registro atual para 1
            UPDATE arquivo
            SET situacao = 1
            WHERE id = v_id;
        END LOOP;

        -- Fecha o cursor
        CLOSE c_arquivos;

        -- Pausa por 2 minutos
        DBMS_SESSION.SLEEP(30);

        -- Commit da transação
        COMMIT;
    END;
END;
/


--- versão com cursores implicitos

BEGIN
    -- Loop através dos registros selecionados usando um cursor implícito
    FOR r_arquivo IN (
        SELECT id
        FROM arquivo
        WHERE situacao = 0
        FOR UPDATE SKIP LOCKED
    ) LOOP
        -- Atualiza a situação do registro atual para 1
        UPDATE arquivo
        SET situacao = 1
        WHERE id = r_arquivo.id;
    END LOOP;

    -- Pausa por 30 segundos
    DBMS_SESSION.SLEEP(30);

    -- Commit da transação
    COMMIT;
END;
/


--fazendo o update de uma vez, sem ter que fazer um loop

DECLARE
    TYPE cur_type IS REF CURSOR;
    c_arquivos cur_type;
BEGIN
    -- Abre o cursor para uma consulta específica
    OPEN c_arquivos FOR
        SELECT id
        FROM arquivo
        WHERE situacao = 0
        FOR UPDATE SKIP LOCKED;

    -- A atualização em uma única instrução dentro de um bloco PL/SQL
    UPDATE arquivo
    SET situacao = 1
    WHERE situacao = 0
      AND CURRENT OF c_arquivos; -- Atualiza apenas os registros selecionados pelo cursor

    -- Fecha o cursor
    CLOSE c_arquivos;

    -- Pausa por 2 minutos
    DBMS_SESSION.SLEEP(120);

    -- Commit da transação
    COMMIT;
END;
/