# Relatório — Integração Supabase no mapa (2026-07-29)

## O que foi feito
Adaptação do `index.html` (passo 4 do plano) para usar Supabase, **tudo de uma vez**, com
**seleção de região no painel**. Tudo local no clone `...\ESTRUTURA-MONITORAMENTO\repo`,
**nada publicado no GitHub**. As tags `<script>` com os dados atuais foram mantidas como backup.

### Mudanças no `index.html`
- **Config Supabase** no `<head>`: URL, chave `anon` (colada), bucket `fotos`, cliente `SB`,
  flag `window.__SB_MODE`.
- **Telas de autenticação** (overlay): carregando / "Entrar com Google" / "não autorizado".
  A interface do mapa fica escondida até logar (`body.authed`).
- **Login Google** via `SB.auth.signInWithOAuth` + tratamento de sessão/retorno OAuth.
- **Perfil e permissões**: ao logar, carrega `perfis` (allowlist), `regioes`,
  `permissoes_regiao` e `config`. Super admin edita todas as regiões; membro só as suas.
- **Seletores de região** nos painéis de desenhar e de foto (só regiões editáveis).
- **Camada `Store`**: criar/editar/apagar linhas e fotos direto nas tabelas `marcacoes`,
  e `loadAll()` que desenha o mapa a partir do banco (em vez das tags embutidas).
- **Fotos no Storage**: upload da imagem redimensionada para o bucket `fotos`
  (`<uid>/arquivo.jpg`), guardando a URL pública em `foto_url`.
- **Removido o fluxo de salvar-no-GitHub por token** (elimina o token exposto);
  o painel virou "Minha conta" (email, papel, sair). Salvamento agora é automático no banco.
- Criado **`setup_storage.sql`** (bucket `fotos` + políticas de acesso).

### Verificação
- `node --check` nos scripts inline: OK (sem erros de sintaxe).
- Servido localmente e aberto no navegador: cliente Supabase inicializa, tela de login
  renderiza, sem erros no console. (Login Google real não testável aqui — precisa do
  provider ativo e conta real.)

## Falta (passos manuais / próximos)
1. Ativar **login Google** no Supabase (Authentication > Providers > Google) + redirect.
2. Rodar **`setup_storage.sql`** no SQL Editor.
3. Testar login ponta a ponta; cadastrar email na allowlist e promover a super_admin.
4. **Migrar as 106 marcações** embutidas (13 ONDA AZUL) para a tabela `marcacoes`
   — cada uma precisa de região (definir estratégia).
5. Distribuir regiões aos membros e testar permissões.
6. Publicar no GitHub (puxando a versão atual antes).

## Segurança
- Revogar o token GitHub antigo exposto (o app não usa mais token).

---

# Adendo — Novas regiões (Sul/Oeste) no index.html funcional

Feito **na versão funcional** `index.html` (não na do Supabase), mantendo todo o conteúdo atual.

- Fonte dos locais: `mapa_secoes_unificado_df_4.html` (Downloads) — mapa do DF inteiro no
  mesmo formato (name/short/lat/lng/address/situacao/regiao).
- Extraídas **273 novas seções** em **9 regiões**, com coordenadas e situação (256 ATIVO, 17 BLOQUEADO):
  Ceilândia 82, Taguatinga 65, Samambaia 37, Gama 33, Recanto das Emas 21, Santa Maria 19,
  Riacho Fundo 9, Estrutural (=SCIA/Estrutural) 5, Sol Nascente (=Sol Nascente/Pôr do Sol) 2.
- `locais` 139 → **412**. Adicionadas 9 cores em REGION_COLORS, 9 itens na legenda, subtítulo
  atualizado (Norte + Sul/Oeste).
- Verificado: `node --check` OK; carregado no navegador com **412 marcadores** e **sem erros**.
- Backup: `index.html.bak_antes_novas_regioes`.

### Restaurantes comunitários (feito)
Adicionados **7 restaurantes** (array `restaurantes` 6 → 13), coordenadas do OpenStreetMap/Nominatim:
Ceilândia, Samambaia, Gama, Santa Maria, Recanto das Emas, Estrutural, Sol Nascente.
Taguatinga e Riacho Fundo (I) **não têm** restaurante comunitário (lista oficial Sedes; Riacho Fundo II tem,
mas fora do pedido). Coordenadas OSM — **conferir/ajustar** se necessário. Verificado no navegador: 13 restaurantes, sem erros.

**Pendências desta etapa:**
- **Água Quente**: não existe como região nas fontes (área rural de Santa Maria) — ficou de fora.
- Coordenadas dos restaurantes vieram do OSM — validar posição.
- Painel "Eleitores por região" continua só com o Norte (falta eleitorado/votos das novas RAs;
  o `votacao_secao_2022_DF.csv` serve pra isso depois).
- Título ainda diz "Região Norte" — avaliar renomear já que agora inclui Sul/Oeste.
