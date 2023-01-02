#include<iostream>
#include<cmath>


double F(double z, int n, int i){
    if(i == n){return z * pow(1 - z, n - 1);}
    else{return z * z * pow(1 - z, i - 1);}
}


int main(){
    double s = 0, z = 0.021;
    for(int n = 1281;n<=75640;n++){
        for(int i=1;i<=n;i++){
            s = s + (F(z, n, i) + 63 * F((1 - z)/63, n, i)) * log2(i);
        }
    }
    s = s / 74360; 
    std::cout<<z << "\n";
    std::cout<<s;
    return 0;
}

