class XWallet {
    isInstalled() {
        const isXWalletInstalled = () => {
            const { kadena } = window;
            return Boolean(kadena && kadena.isKadena);
        };

        if (document.readyState === "complete") {
            return Promise.resolve(isXWalletInstalled());
        }

        return new Promise((resolve) => {
            window.addEventListener('load', () => {
                resolve(isXWalletInstalled())
            });
        });
    }

    async isConnected(networkId) {
        const { kadena } = window;

        const response = await kadena.request({
            method: 'kda_checkStatus',
            networkId: networkId,
        });

        console.log(response);

        return response.status === "success";
    }

    async connect(networkId) {
        const { kadena } = window;

        const response = await kadena.request({
            method: 'kda_connect',
            networkId: networkId
        });

        console.log(response);
    }

    async getAccount(networkId) {
        const { kadena } = window;

        const response = await kadena.request({
            method: 'kda_requestAccount',
            networkId,
        });

        console.log(response);

        return response.wallet;
    }

    async disconnect(networkId) {
        const { kadena } = window;

        const response = await kadena.request({
            method: 'kda_disconnect',
            networkId: networkId
        });

        console.log(response);
    }

    onAccountChanged(callback) {
        this.on('res_accountChange', callback);
    }

    onStatusChanged(callback) {
        this.on('res_checkStatus', callback);
    }

    on(eventName, callback) {
        const { kadena } = window;

        if (!kadena) {
            return;
        }

        kadena.on(eventName, callback);
    }
}

export default new XWallet();