import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// [Previous test content remains unchanged, adding new tests]

Clarinet.test({
  name: "Test path status management",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pathlens', 'create-path',
        [types.ascii("Software Engineer"), types.ascii("Path description")],
        deployer.address
      ),
      Tx.contractCall('pathlens', 'update-path-status',
        [types.uint(1), types.ascii("paused")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Test mentor approval flow",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pathlens', 'request-mentor',
        [types.principal(wallet1.address)],
        deployer.address
      ),
      Tx.contractCall('pathlens', 'approve-mentorship',
        [types.principal(deployer.address)],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);
  }
});
