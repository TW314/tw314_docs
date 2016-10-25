USE `tw314`;
DROP procedure IF EXISTS `PRC_GERAR_TICKET`;

DELIMITER $$
USE `tw314`$$
CREATE PROCEDURE `PRC_GERAR_TICKET`( IN  P_EMPRESA_ID 	   		INT	   ,
									 IN  P_SERVICO_ID 	   		INT	   ,
                                     IN  P_PRIORITARIO 		BOOLEAN	   ,
                                     OUT P_TICKET	   		VARCHAR(12),
                                     OUT P_CODIGO_ACESSO   	VARCHAR(12))
BEGIN
	DECLARE V_NR_TICKET 		INT    ;
    DECLARE V_ULTIMO_TICKET		INT	   ;
    DECLARE V_SIGLA_SERVICO VARCHAR(10);
    -- DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET EXCEPTION = 0;
    
    -- SET EXCEPTION = 0;
    START TRANSACTION;
		IF (P_EMPRESA_ID IS NOT NULL && P_SERVICO_ID IS NOT NULL && P_PRIORITARIO IS NOT NULL) THEN
			SELECT MAX(NUMERO_TICKET)
			  INTO V_ULTIMO_TICKET
			  FROM TICKETS
			 WHERE EMPRESAID = P_EMPRESA_ID
			   AND SERVICOID = P_SERVICO_ID
			   AND DATE(DATA_HORA_EMISSAO) = DATE(SYSDATE());
			
            -- IF (EXCEPTION = 0) THEN
				IF (V_ULTIMO_TICKET IS NULL) THEN
					SET V_NR_TICKET = 001;
				ELSE
					SET V_NR_TICKET = V_ULTIMO_TICKET + 1;
				END IF;
				
				SELECT SIGLA 
				  INTO V_SIGLA_SERVICO 
				  FROM SERVICOS 
				 WHERE ID = P_SERVICO_ID;
				
				/* 
				 * 2016-10-20 PEDRO TODO: ALTERAR FORMA DO CODIGO DE ACESSO 
				 * 2016-10-20 PEDRO TODO: A TABELA DE TICKET TERA UM CAMPO DE PRIORIDADE, NAO ESQUECER DE PASSAR O PARAM P_PRIORIDADE NESSE CAMPO
				 */
				-- IF (EXCEPTION = 0) THEN
					IF (V_SIGLA_SERVICO IS NOT NULL) THEN
						INSERT INTO TICKETS
						VALUES (V_NR_TICKET, SYSDATE(), CONCAT(DATE_FORMAT(SYSDATE(), '%y%m%d'),V_SIGLA_SERVICO,V_NR_TICKET), 
								SYSDATE(), SYSDATE(), 1, P_EMPRESA_ID, P_SERVICO_ID);
						COMMIT;
					END IF;

					SELECT CODIGO_ACESSO, CONCAT(V_SIGLA_SERVICO, V_NR_TICKET)
					  INTO P_CODIGO_ACESSO, P_TICKET
					  FROM TICKETS
					 WHERE NUMERO_TICKET = V_NR_TICKET
					   AND EMPRESAID = P_EMPRESA_ID
					   AND SERVICOID = P_SERVICO_ID
					   AND DATE(DATA_HORA_EMISSAO) = DATE(SYSDATE());
                -- END IF;
			-- END IF;
		END IF;
END;$$

DELIMITER ;