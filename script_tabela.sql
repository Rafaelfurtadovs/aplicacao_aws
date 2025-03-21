<?php include "../inc/dbinfo.inc"; ?>

<html>
<body>
<h1>Cadastro de Produtos</h1>
<?php

/* Conectar ao PostgreSQL e selecionar o banco de dados. */
$constring = "host=" . DB_SERVER . " dbname=" . DB_DATABASE . " user=" . DB_USERNAME . " password=" . DB_PASSWORD ;
$connection = pg_connect($constring);

if (!$connection) {
    echo "Falha na conexão com o PostgreSQL";
    exit;
}

/* Garantir que a tabela PRODUTOS exista e inclua a nova coluna. */
VerifyProdutosTable($connection, DB_DATABASE);

/* Se os campos do formulário forem preenchidos, adicionar um registro à tabela PRODUTOS. */
$produto_nome = htmlentities($_POST['NOME']);
$produto_preco = htmlentities($_POST['PRECO']);
$produto_data_criacao = htmlentities($_POST['DATA_CRIACAO']);
$produto_descricao = htmlentities($_POST['DESCRICAO']);

if (strlen($produto_nome) || strlen($produto_preco) || strlen($produto_data_criacao) || strlen($produto_descricao)) {
    AddProduto($connection, $produto_nome, $produto_preco, $produto_data_criacao, $produto_descricao);
}

?>

<!-- Formulário de entrada -->
<form action="<?PHP echo $_SERVER['SCRIPT_NAME'] ?>" method="POST">
  <table border="0">
    <tr>
      <td>Nome</td>
      <td>Preço</td>
      <td>Data de Criação</td>
      <td>Descrição</td>
    </tr>
    <tr>
      <td>
        <input type="text" name="NOME" maxlength="255" size="30" required />
      </td>
      <td>
        <input type="number" name="PRECO" step="0.01" required />
      </td>
      <td>
        <input type="date" name="DATA_CRIACAO" required />
      </td>
      <td>
        <input type="text" name="DESCRICAO" maxlength="500" size="50" />
      </td>
      <td>
        <input type="submit" value="Adicionar Produto" />
      </td>
    </tr>
  </table>
</form>

<!-- Exibir dados da tabela -->
<table border="1" cellpadding="2" cellspacing="2">
  <tr>
    <td>ID</td>
    <td>Nome</td>
    <td>Preço</td>
    <td>Data de Criação</td>
    <td>Descrição</td>
  </tr>

<?php

$result = pg_query($connection, "SELECT * FROM produtos");

while ($query_data = pg_fetch_row($result)) {
    echo "<tr>";
    echo "<td>", $query_data[0], "</td>",
         "<td>", $query_data[1], "</td>",
         "<td>", $query_data[2], "</td>",
         "<td>", $query_data[3], "</td>",
         "<td>", $query_data[4], "</td>";
    echo "</tr>";
}
?>
</table>

<!-- Limpar recursos -->
<?php
pg_free_result($result);
pg_close($connection);
?>
</body>
</html>


<?php

/* Adicionar um produto à tabela. */
function AddProduto($connection, $nome, $preco, $data_criacao, $descricao) {
    $n = pg_escape_string($nome);
    $p = pg_escape_string($preco);
    $d = pg_escape_string($data_criacao);
    $desc = pg_escape_string($descricao);

    $query = "INSERT INTO produtos (nome, preco, data_criacao, descricao) VALUES ('$n', '$p', '$d', '$desc');";

    if (!pg_query($connection, $query)) echo("<p>Erro ao adicionar produto.</p>");
}

/* Verificar se a tabela existe e incluir a nova coluna caso necessário. */
function VerifyProdutosTable($connection, $dbName) {
    if (!TableExists("produtos", $connection, $dbName)) {
        // Criar a tabela caso não exista
        $query = "CREATE TABLE produtos (
            id SERIAL PRIMARY KEY,
            nome VARCHAR(255),
            preco NUMERIC(10, 2),
            data_criacao DATE,
            descricao TEXT
        )";

        if (!pg_query($connection, $query)) echo("<p>Erro ao criar tabela.</p>");
    } else {
        // Adicionar a coluna 'descricao' caso ela não exista
        if (!ColumnExists("produtos", "descricao", $connection)) {
            $alterQuery = "ALTER TABLE produtos ADD COLUMN descricao TEXT;";
            if (!pg_query($connection, $alterQuery)) echo("<p>Erro ao adicionar coluna 'descricao'.</p>");
        }
    }
}

/* Verificar a existência de uma tabela. */
function TableExists($tableName, $connection, $dbName) {
    $t = strtolower(pg_escape_string($tableName));
    
    // Consultar o esquema padrão 'public'
    $query = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME = '$t';";
    $checktable = pg_query($connection, $query);

    return (pg_num_rows($checktable) > 0);
}

/* Verificar se uma coluna existe em uma tabela. */
function ColumnExists($tableName, $columnName, $connection) {
    $t = strtolower(pg_escape_string($tableName));
    $c = strtolower(pg_escape_string($columnName));

    // Consultar colunas na tabela
    $query = "SELECT column_name FROM information_schema.columns WHERE table_name='$t' AND column_name='$c';";
    $checkcolumn = pg_query($connection, $query);

    return (pg_num_rows($checkcolumn) > 0);
}
?>
