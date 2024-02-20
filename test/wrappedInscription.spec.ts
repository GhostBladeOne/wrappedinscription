import { deployContract } from './shared/utilities';
import { Fixture  } from 'ethereum-waffle'
import { Wallet,constants } from 'ethers'
import {  waffle, ethers} from 'hardhat'
import {TestERC20 ,WrappedInscription} from '../typechain'
import { expect } from 'chai';
import {time ,} from '@nomicfoundation/hardhat-network-helpers'


describe('WrappedInscription',  async ()=> {

   let bob:Wallet
   let alice:Wallet

   const wrappedFixture:Fixture<{
      token: TestERC20
     inscription: WrappedInscription
   }>  = async () => {
        const token = await  deployContract('TestERC20' , [1000000]) as TestERC20;
        const inscription = await deployContract('WrappedInscription',  [token.address, '0xd893ca77b3122cb6c480da7f8a12cb82e19542076f5895f21446258dc473a7c2']) as WrappedInscription;

        return {
          token,
          inscription
        }

   }

    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    before('create fixture loader', async () => {
    ;[bob, alice] = await (ethers as any).getSigners()
    loadFixture = waffle.createFixtureLoader([bob, alice])
   })

   let token: TestERC20;
   let inscription: WrappedInscription;

    beforeEach('load fixture', async () => {
    ;({ token, inscription } = await loadFixture(
      wrappedFixture
    ))

       await token.connect(bob).approve(inscription.address, constants.MaxUint256);
       await token.connect(alice).approve(inscription.address, constants.MaxUint256);
       await token.connect(alice).mint(alice.address, 1000000);
  })
  

  describe(('inscription'), async()=> {

    it('#mint', async ()=> {
          const  beforeAmount = await token.balanceOf(bob.address);
          const  beforeContractAmount = await token.balanceOf(inscription.address);

          
          await inscription.mint(100);

          const afterAmount = await  token.balanceOf(bob.address);
          const afterContractAmount = await  token.balanceOf(inscription.address);

          expect(afterAmount).to.eq(beforeAmount.sub(100))
          expect(afterContractAmount).to.eq(beforeContractAmount.add(100));

         await inscription.setUserBalance(bob.address, 100);

          await inscription.connect(bob).redeem(100, 259300);

          const len = await  inscription.getUserRedeemsLength(bob.address);

          expect(len).to.eq(1);

           await  time.increase(459300);

          
           await inscription.finalizeRedeem(0);

            const  beforeAmountinscription = await token.balanceOf(bob.address);
          const  beforeContractAmountinscription = await token.balanceOf(inscription.address);

         
            expect(beforeAmountinscription).to.eq(1000000)
            expect(beforeContractAmountinscription).to.eq(0)

               const len1 = await  inscription.getUserRedeemsLength(bob.address);

                 expect(len1).to.eq(0);




          

          
    })
    
  })


  
})