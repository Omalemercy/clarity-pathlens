import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test create path functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pathlens', 'create-path', 
        [types.ascii("Software Engineer"), types.ascii("Path to becoming a senior developer")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    const response = chain.callReadOnlyFn(
      'pathlens',
      'get-path',
      [types.uint(1)],
      deployer.address
    );
    
    response.result.expectOk().expectSome();
  }
});

Clarinet.test({
  name: "Test milestone management",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create path first
    let block = chain.mineBlock([
      Tx.contractCall('pathlens', 'create-path',
        [types.ascii("Software Engineer"), types.ascii("Path description")],
        deployer.address
      )
    ]);
    
    // Add milestone
    block = chain.mineBlock([
      Tx.contractCall('pathlens', 'add-milestone',
        [types.uint(1), types.ascii("Learn JavaScript"), types.ascii("Master JS basics"), types.uint(30)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Try to complete milestone as unauthorized user
    block = chain.mineBlock([
      Tx.contractCall('pathlens', 'complete-milestone',
        [types.uint(1)],
        wallet1.address
      )
    ]);
    
    block.receipts[0].result.expectErr().expectUint(102); // err-unauthorized
    
    // Complete milestone as path owner
    block = chain.mineBlock([
      Tx.contractCall('pathlens', 'complete-milestone',
        [types.uint(1)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Test mentor connections",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pathlens', 'connect-mentor',
        [types.principal(wallet1.address)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
    
    const response = chain.callReadOnlyFn(
      'pathlens',
      'get-user-mentors',
      [types.principal(deployer.address)],
      deployer.address
    );
    
    response.result.expectOk().expectSome();
  }
});
