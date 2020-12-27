# **Project description**

Написание контракта Solidity, реализующего паттерн commit-reveal, и тестов в testnet Ethereum.

Контракт реализует логику аукциона "вслепую".
Инициируется аукцион, у которого задается biddingTime, revealTime, beneficiary и lotName.
Во время biddingTime участники делают заявки. 
Во время revealTime идет процесс раскрытия. 
По итогу выявляется победитель и происходит трансфер по адресу beneficiary.

# **Install**

`npm install -g ganache-cli`

`npm install -g truffle`

# **Build**

`truffle build`

# **Run**

Запустите в отдельном терминале ganache-cli

`ganache-cli`

Задеплойте контракт

`truffle deploy`

# **Test**
Для запуска тестов на JavaScript необходимо сделать

`npm install`

Запуск тестов на Javascript и Solidity

`truffle test`