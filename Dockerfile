FROM ubuntu:noble

# いったんリポジトリを更新
RUN apt-get update

# 事前に必要となるパッケージをインストール
# 「--no-install-recommends」でインストールするパッケージを必須のものだけに絞り、
# 推奨パッケージが一緒にインストールされないように
RUN apt-get install -y --no-install-recommends ca-certificates wget gnupg

# のちの署名検証に使用するPerforceの公開鍵を登録
RUN wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | tee /usr/share/keyrings/perforce.gpg

# Perforceのリポジトリを登録
# signed-by=/usr/share/keyrings/perforce.gpgで、先で登録した公開鍵を署名検証の際に使用するよう設定
RUN echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu noble release" > /etc/apt/sources.list.d/perforce.list

# 再度リポジトリの更新を行い、登録したリポジトリを反映する 
# ここで署名検証が行われる
RUN apt-get update

# p4-serverをインストール
RUN apt-get install -y p4-server

# 実行時に使うエントリポイントを入れる
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 実行
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
