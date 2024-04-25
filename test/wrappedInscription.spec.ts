import { deployContract } from './shared/utilities';
import { Fixture  } from 'ethereum-waffle'
import { Wallet,constants } from 'ethers'
import {  waffle, ethers} from 'hardhat'
import {TestERC20 ,WrappedInscription} from '../typechain'
import { expect } from 'chai';
import {time ,} from '@nomicfoundation/hardhat-network-helpers'


const tickhash = '0xd893ca77b3122cb6c480da7f8a12cb82e19542076f5895f21446258dc473a7c2';
describe('WrappedInscription',  async ()=> {

   let bob:Wallet
   let alice:Wallet

   const wrappedFixture:Fixture<{
      token: TestERC20
     inscription: WrappedInscription
   }>  = async () => {
        const token = await  deployContract('TestERC20' , [1000000]) as TestERC20;
        const inscription = await deployContract('WrappedInscription',  [token.address, tickhash]) as WrappedInscription;

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
          await inscription.mint(tickhash,100);
          const afterAmount = await  token.balanceOf(bob.address);
          const afterContractAmount = await  token.balanceOf(inscription.address);

          expect(afterAmount).to.eq(beforeAmount.sub(100))
          expect(afterContractAmount).to.eq(beforeContractAmount.add(100));

         await inscription.approve(bob.address, 100);
        

         const balanceOf =  await inscription.balanceOf(bob.address)

         expect(balanceOf).to.eq(100);

        const  beforeAmountwithdraw = await token.balanceOf(bob.address);
        const  beforeContractAmountwithdraw = await token.balanceOf(inscription.address);
         await inscription.connect(bob).withdraw( 100 );

        const afterAmountwithdraw = await  token.balanceOf(bob.address);
        const afterContractAmountwithdraw = await  token.balanceOf(inscription.address);
        
        
        expect(afterAmountwithdraw).to.eq(beforeAmountwithdraw.add(100))
        expect(afterContractAmountwithdraw).to.eq(beforeContractAmountwithdraw.sub(100));
        expect( await inscription.balanceOf(bob.address)).to.eq(0);
    })
  })


  describe("set config", async ()=> {
       it("#setMaxLimit", async ()=> {
              await  inscription.setMaxLimit(100000000);
            expect(await inscription.maxLimit()).to.eq(100000000);
       })
       it("#setLimiter" , async ()=> {
            await inscription.setLimiter(true);
            expect(await inscription.limiter()).to.eq(true);
       })

      it("#setMintUser" , async ()=> {
            await inscription.setMintUser([bob.address],true);
            expect(await inscription.mintUser(bob.address)).to.eq(true);
      })
      
      it("#withdrawToken", async ()=> {
            expect(await token.balanceOf(inscription.address)).to.eq(0);
            await  token.transfer(inscription.address, 1000000);
            expect(await token.balanceOf(inscription.address)).to.eq(1000000);
            await inscription.withdrawToken(token.address,1000000);
             expect(await token.balanceOf(inscription.address)).to.eq(0);
      })
       
  })

  describe("error", async()=> {
    it("#Prohibition of convertibility" , async ()=> {
          await inscription.mint(tickhash,100);
          expect( inscription.mint(tickhash,100)).to.be.reverted
    }) 

    it("#maxLimit" , async ()=> {
          expect( inscription.mint(tickhash,100)).to.be.reverted
    })

    it("# withdrawToken error " , async ()=> {
        await  token.transfer(inscription.address, 1000000);
        expect(inscription.connect(alice).withdrawToken(token.address,1000000)).to.be.reverted
    })
    
    it("# forbidden",async()=> {
          await inscription.setForbidden(true);
            expect( inscription.connect(bob).withdraw( 100 )).to.be.reverted
                   
    })
     
  })

  
})