Delimiter $$
CREATE PROCEDURE `PRC_REORDENA_FILA`(   IN  P_NUMERO_SEQUENCIAL         VARCHAR(20) ,
										IN  P_EMPRESA					INT			,
                                        IN  P_SERVICO					INT			,
										OUT P_CODIGO 					INT			,
                                        OUT P_MENSAGEM					VARCHAR(255))
BEGIN

    DECLARE DONE INT DEFAULT FALSE;
	DECLARE V_EMPRESA 			INT;
    DECLARE V_SERVICO 			INT;
    DECLARE V_NUMERO_SEQUENCIAL INT;


    DECLARE CUR_TICKET CURSOR FOR
		SELECT numero_sequencial,
			   empresaId		,
               servicoId
        FROM ticket
        WHERE  empresaid               = P_EMPRESA
          AND  servicoId		       = P_SERVICO
          AND  numero_sequencial      >= P_NUMERO_SEQUENCIAL
          AND  DATE(data_hora_emissao) = DATE(SYSDATE())
        ORDER BY numero_sequencial DESC;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;


    IF(P_NUMERO_SEQUENCIAL IS NOT NULL) THEN
        IF(P_EMPRESA IS NOT NULL) THEN
			IF(P_SERVICO IS NOT NULL) THEN

				OPEN CUR_TICKET;

				READ_LOOP: LOOP
					FETCH CUR_TICKET INTO V_NUMERO_SEQUENCIAL,
										  V_EMPRESA          ,
										  V_SERVICO;
					IF DONE THEN
					  LEAVE READ_LOOP;
					END IF;

					START TRANSACTION;
						UPDATE ticket
						   SET numero_sequencial 		= numero_sequencial + 1
						 WHERE numero_sequencial 		= V_NUMERO_SEQUENCIAL
						   AND empresaid		 		= V_EMPRESA
						   AND servicoId		 	    = V_SERVICO
                           AND  DATE(data_hora_emissao) = DATE(SYSDATE());

					COMMIT;

					SELECT 0, 'Sucesso'
					  INTO P_CODIGO, P_MENSAGEM;
					END LOOP;
			ELSE
				SELECT -3, 'Erro: Parâmetro de entrada P_SERVICO vazio. Realizando rollback das alterações.'
				  INTO P_CODIGO, P_MENSAGEM;
				ROLLBACK;
			END IF;
        ELSE
			SELECT -2, 'Erro: Parâmetro de entrada P_EMPRESA vazio. Realizando rollback das alterações.'
			  INTO P_CODIGO, P_MENSAGEM;
			ROLLBACK;
		END IF;
    ELSE
		SELECT -1, 'Erro: Parâmetro de entrada P_CODIGO_ACESSO vazio. Realizando rollback das alterações.'
		  INTO P_CODIGO, P_MENSAGEM;
		ROLLBACK;
    END IF;


END
$$
