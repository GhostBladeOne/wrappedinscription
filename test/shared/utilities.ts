import bn from 'bignumber.js'
import { ethers } from 'hardhat'



export async function deployContract(name:string, args:any, contractOptions?:any ) {
  const contractFactory = await ethers.getContractFactory(name, contractOptions??{});
  return await contractFactory.deploy(...args);
}
export async function contractAt(name:string, address:string,contractOptions:any) {
  const contractFactory = await ethers.getContractFactory(name,contractOptions);
  return await contractFactory.attach(address);
}
export function sleep(ms:any) {
  return new Promise(resolve => setTimeout(resolve, ms));
}