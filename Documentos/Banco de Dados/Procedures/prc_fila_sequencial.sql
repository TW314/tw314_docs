CREATE PROCEDURE `PRC_FILA_SEQUENCIAL`( IN P_CODIGO_ACESSO VARCHAR(20) ,
										OUT P_CODIGO 			INT		,
                                        OUT P_MENSAGEM		VARCHAR(255))
BEGIN
	DECLARE C_TICKET						INT;
	DECLARE V_ULTIMO_SEQUENCIAL 			INT;
    DECLARE V_PRIMEIRO_SEQUENCIAL			INT;
    DECLARE V_ULTIMO_SEQUENCIAL_PRIORITARIO INT;
    DECLARE V_SEQUENCIAL 					INT;
    DECLARE V_SERVICO						INT;
    DECLARE	V_EMPRESA						INT;
    DECLARE V_PRIORITARIO					INT;
    DECLARE V_CONFERE_SEQUENCIAL			INT;
    DECLARE V_CONFERE_ANTERIOR				INT;
    DECLARE V_CODIGO_PROCEDURE_REORDENAR    INT;
    DECLARE V_MENSAGEM_PROCEDURE_REORDENAR  VARCHAR(255);

    SET V_CODIGO_PROCEDURE_REORDENAR = 0;

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
					SELECT prioridadeTicketId
					  INTO V_PRIORITARIO
                      FROM ticket
					 WHERE codigo_acesso = P_CODIGO_ACESSO;

                     IF(V_PRIORITARIO IS NOT NULL) THEN

                        IF(V_PRIORITARIO = 1) THEN
							SELECT MIN(numero_sequencial), MAX(numero_sequencial)
							  INTO V_PRIMEIRO_SEQUENCIAL, V_ULTIMO_SEQUENCIAL
                              FROM ticket
							 WHERE statusTicketId = 1
							   AND DATE(data_hora_emissao) = DATE(SYSDATE());
							
                            SELECT MAX(numero_sequencial)
							  INTO V_ULTIMO_SEQUENCIAL_PRIORITARIO
                              FROM ticket
							 WHERE statusTicketId = 1
							   AND DATE(data_hora_emissao) = DATE(SYSDATE())
                               AND prioridadeTicketId = 1
                               AND numero_sequencial BETWEEN V_PRIMEIRO_SEQUENCIAL 
														 AND V_ULTIMO_SEQUENCIAL;
							
                            IF(V_ULTIMO_SEQUENCIAL_PRIORITARIO IS NULL) THEN
								IF (V_PRIMEIRO_SEQUENCIAL IS NULL) THEN
									SET V_SEQUENCIAL := 1;
								ELSE
									SELECT V_PRIMEIRO_SEQUENCIAL
									  INTO V_SEQUENCIAL;
									
									CALL PRC_REORDENA_FILA(V_SEQUENCIAL, V_EMPRESA, V_SERVICO, @CODIGO, @MENSAGEM);
									SELECT @CODIGO,
										   @MENSAGEM
									INTO   V_CODIGO_PROCEDURE_REORDENAR,
										   V_MENSAGEM_PROCEDURE_REORDENAR;
								END IF;
                            ELSE
								SELECT MAX(numero_sequencial)
								  INTO V_ULTIMO_SEQUENCIAL_PRIORITARIO
								  FROM ticket
								 WHERE empresaId 		  = V_EMPRESA
								   AND servicoId 		  = V_SERVICO
								   AND prioridadeTicketId = V_PRIORITARIO
								   AND DATE(data_hora_emissao) = DATE(SYSDATE());

								IF (V_ULTIMO_SEQUENCIAL_PRIORITARIO IS NULL) THEN
									SET V_SEQUENCIAL := 1;
								ELSE
									SET V_SEQUENCIAL := V_ULTIMO_SEQUENCIAL_PRIORITARIO + 3;
								END IF;

								SELECT COUNT(*)
								 INTO  V_CONFERE_SEQUENCIAL
								 FROM  ticket
								 WHERE empresaId 		  = V_EMPRESA
								   AND servicoId 		  = V_SERVICO
								   AND numero_sequencial  = V_SEQUENCIAL
								   AND DATE(data_hora_emissao) = DATE(SYSDATE());
								
								IF(V_CONFERE_SEQUENCIAL > 0) THEN
									CALL PRC_REORDENA_FILA(V_SEQUENCIAL, V_EMPRESA, V_SERVICO, @CODIGO, @MENSAGEM);
									SELECT @CODIGO,
										   @MENSAGEM
									INTO   V_CODIGO_PROCEDURE_REORDENAR,
										   V_MENSAGEM_PROCEDURE_REORDENAR;
								ELSE
									IF(V_ULTIMO_SEQUENCIAL_PRIORITARIO IS NOT NULL) THEN
									
										SELECT COUNT(*)
										INTO  V_CONFERE_ANTERIOR
										FROM  ticket
										WHERE empresaId 		  = V_EMPRESA
										  AND servicoId 		  = V_SERVICO
										  AND numero_sequencial   > V_ULTIMO_SEQUENCIAL_PRIORITARIO
										  AND numero_sequencial   < V_SEQUENCIAL ;
										 
										 IF(V_CONFERE_ANTERIOR = 0) THEN
											SET V_SEQUENCIAL := V_ULTIMO_SEQUENCIAL_PRIORITARIO + 1;
										 ELSEIF(V_CONFERE_ANTERIOR = 1) THEN
											SET V_SEQUENCIAL := V_ULTIMO_SEQUENCIAL_PRIORITARIO + 2;
										 END IF;
									END IF;
								END IF;
							END IF;
                        ELSE
							SELECT MAX(numero_sequencial)
							  INTO V_ULTIMO_SEQUENCIAL
							  FROM ticket
							 WHERE empresaId = V_EMPRESA
							   AND servicoId = V_SERVICO
                               AND DATE(data_hora_emissao) = DATE(SYSDATE());

							IF (V_ULTIMO_SEQUENCIAL IS NULL) THEN
								SET V_SEQUENCIAL := 1;
							ELSE
								SET V_SEQUENCIAL := V_ULTIMO_SEQUENCIAL + 1;
							END IF;
						END IF;

                        IF(V_CODIGO_PROCEDURE_REORDENAR = 0) THEN

							START TRANSACTION;
								UPDATE ticket
								   SET numero_sequencial = V_SEQUENCIAL
								 WHERE codigo_acesso 	 = P_CODIGO_ACESSO;

								COMMIT;

								SELECT 0, 'Sucesso'
								  INTO P_CODIGO, P_MENSAGEM;
						ELSE
						  SELECT 5, 'Erro ao tentar reordenar a fila. Realizando rollback das alterações.'
						    INTO P_CODIGO, P_MENSAGEM;
						  ROLLBACK;
						END IF;
					ELSE
						SELECT 4, 'Erro ao selecionar Prioridade do Ticket. Realizando rollback das alterações.'
						  INTO P_CODIGO, P_MENSAGEM;
						ROLLBACK;
					END IF;
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