CREATE PROCEDURE `PRC_FILA_SEQUENCIAL`( IN P_CODIGO_ACESSO VARCHAR(20) ,
										OUT P_CODIGO 			INT		,
                                        OUT P_MENSAGEM		VARCHAR(255))
BEGIN
	DECLARE C_TICKET	INT;
	DECLARE V_ULTIMO_SEQUENCIAL INT;
    DECLARE V_SEQUENCIAL 		INT;
    DECLARE V_SERVICO			INT;
    DECLARE	V_EMPRESA			INT;
    
    IF (P_CODIGO_ACESSO IS NOT NULL) THEN
		SELECT COUNT(*)
	      INTO C_TICKET
		  FROM ticket
		 WHERE codigo_acesso = P_CODIGO_ACESSO;
         
         IF (C_TICKET > 0) THEN
			SELECT servicoId
			  INTO V_SERVICO
              FROM ticket
			 WHERE codigo_acesso = P_CODIGO_ACESSO;
			
            IF (V_SERVICO IS NOT NULL) THEN
				SELECT empresaId
				  INTO V_EMPRESA
				  FROM ticket
				 WHERE codigo_acesso = P_CODIGO_ACESSO;
                
                IF (V_EMPRESA IS NOT NULL) THEN
					SELECT MAX(numero_sequencial)
					  INTO V_ULTIMO_SEQUENCIAL
                      FROM ticket
					 WHERE empresaId = V_EMPRESA
                       AND servicoId = V_SERVICO;
                       
					IF (V_ULTIMO_SEQUENCIAL IS NULL) THEN
						SET V_SEQUENCIAL := 1;
                    ELSE
						SET V_SEQUENCIAL := V_ULTIMO_SEQUENCIAL + 1;
                    END IF;
                    
					START TRANSACTION;
						UPDATE ticket
						   SET numero_sequencial = V_SEQUENCIAL
						 WHERE codigo_acesso = P_CODIGO_ACESSO;
						
                        COMMIT;
                        
                        SELECT 0, 'Sucesso'
						  INTO P_CODIGO, P_MENSAGEM;
                ELSE
					SELECT 3, 'Erro ao selecionar Empresa do Ticket. Realizando rollback das alterações.'
					  INTO P_CODIGO, P_MENSAGEM;
					ROLLBACK;
                END IF;
			ELSE
				SELECT 2, 'Erro ao selecionar Serviço do Ticket. Realizando rollback das alterações.'
				  INTO P_CODIGO, P_MENSAGEM;
				ROLLBACK;
            END IF;
            
         ELSE
			SELECT 1, 'Erro: Ticket inexistente na base. Realizando rollback das alterações.'
			  INTO P_CODIGO, P_MENSAGEM;
			ROLLBACK;
         END IF;
    ELSE
		SELECT -1, 'Erro: Parâmetro de entrada vazio. Realizando rollback das alterações.'
		  INTO P_CODIGO, P_MENSAGEM;
		ROLLBACK;
    END IF;

END